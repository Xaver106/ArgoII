{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.common.dnscrypt;
  inherit (lib) mkEnableOption mkIf;
  inherit (config) hostSpec;

  # Empty list -> empty file when distractions are allowed
  blockedNames = if hostSpec.distractions then [ ] else (import ./blocklist.nix).distractions;
  blocklistFile = pkgs.writeText "dnscrypt-blocklist.txt" (
    lib.concatStringsSep "\n" blockedNames + "\n"
  );
  StateDirectory = "/var/lib/dnscrypt-proxy";
  # DoH (local) settings
  dohPort = 3000;
  dohPath = "/dns-query";
  dohUrl = "https://127.0.0.1:${toString dohPort}${dohPath}";
  certDir = "/var/lib/dnscrypt-doh";
  caFile = "${certDir}/ca.pem";
  certFile = "${certDir}/cert.pem";
  keyFile = "${certDir}/key.pem";
  credDir = "/run/credentials/${config.systemd.services.dnscrypt-proxy.name or "dnscrypt-proxy.service"}";

  bypassResolvers = [
    "2620:fe::fe"
    "9.9.9.9"
    "149.112.112.112"
    "2620:fe::9"
    "1.1.1.1"
  ];
  bypassResolvConf = lib.concatMapStrings (r: "nameserver ${r}\n") bypassResolvers;
in
{

  options.common.dnscrypt = {
    enable = mkEnableOption "dnscrypt-proxy";
  };

  config = mkIf cfg.enable {

    networking = {
      nameservers = [
        "127.0.0.1"
        "::1"
      ];
      dhcpcd.extraConfig = "nohook resolv.conf"; # If using dhcpcd
      networkmanager.dns = "none"; # If using NetworkManager
    };
    services.resolved.enable = lib.mkForce false;

    # Self-signed cert for the local DoH server; generated once, key stays root-only
    # To rotate the certificate, delete /var/lib/dnscrypt-doh and run systemctl restart dnscrypt-proxy-doh-cert dnscrypt-proxy.
    systemd.services.dnscrypt-proxy-doh-cert = {
      description = "Generate self-signed certificate for dnscrypt-proxy local DoH";
      wantedBy = [ "multi-user.target" ];
      before = [ "dnscrypt-proxy.service" ];
      path = [ pkgs.openssl ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "dnscrypt-doh"; # /var/lib/dnscrypt-doh, 0755 root
        UMask = "0077";
      };
      script = ''
        set -euo pipefail
        [ -s ${caFile} ] && [ -s ${certFile} ] && [ -s ${keyFile} ] && exit 0
        rm -f ${caFile} ${certFile} ${keyFile}

        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT   # the CA key never leaves this temp dir

        # Throwaway CA (key is deleted on exit)
        openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
          -sha256 -days 3650 -subj "/CN=dnscrypt-proxy local DoH CA" \
          -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
          -addext "keyUsage=critical,keyCertSign,cRLSign" \
          -keyout "$tmp/ca.key" -out ${caFile}

        # Leaf for the DoH server (CA:FALSE)
        openssl req -new -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
          -subj "/CN=dnscrypt-proxy local DoH" \
          -keyout ${keyFile} -out "$tmp/leaf.csr"

        cat > "$tmp/leaf.ext" <<EOF
        basicConstraints=critical,CA:FALSE
        keyUsage=critical,digitalSignature
        extendedKeyUsage=serverAuth
        subjectAltName=IP:127.0.0.1,IP:::1,DNS:localhost
        EOF

        openssl x509 -req -in "$tmp/leaf.csr" -CA ${caFile} -CAkey "$tmp/ca.key" \
          -CAserial "$tmp/ca.srl" -CAcreateserial -sha256 -days 3650 \
          -extfile "$tmp/leaf.ext" -out ${certFile}

        openssl verify -CAfile ${caFile} ${certFile}
        chmod 0644 ${caFile} ${certFile}
      '';
    };

    systemd.services.dnscrypt-proxy = {
      requires = [ "dnscrypt-proxy-doh-cert.service" ];
      after = [ "dnscrypt-proxy-doh-cert.service" ];
      serviceConfig.LoadCredential = [
        "doh-cert.pem:${certFile}"
        "doh-key.pem:${keyFile}"
      ];
    };

    services.dnscrypt-proxy = {
      # TODO: Forwarding for .local and fritz.box to DHCP or local DNS directly
      enable = true;
      settings = {

        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];

        ignore_system_dns = true;
        bootstrap_resolvers = [
          "[2620:fe::fe]:53"
          "9.9.9.11:53"
          "1.1.1.1:53"
        ];

        local_doh = {
          listen_addresses = [ "127.0.0.1:${toString dohPort}" ];
          path = dohPath;
          cert_file = "${credDir}/doh-cert.pem";
          cert_key_file = "${credDir}/doh-key.pem";
        };

        sources = {
          public-resolvers = {
            urls = [
              "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
              "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
            ];
            minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3"; # See https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
            cache_file = "${StateDirectory}/public-resolvers.md";
          };
        };
        
        server_names = [
          "quad9-dnscrypt-ip6-filter-pri"
          "quad9-dnscrypt-ip4-filter-pri"
        ];

        # Use servers reachable over IPv6 -- Do not enable if you don't have IPv6 connectivity
        ipv6_servers = hostSpec.hasIPv6Internet;
        block_ipv6 = (!hostSpec.hasIPv6Internet);
        http3 = true;

        blocked_query_response = "refused";
        blocked_names.blocked_names_file = "${blocklistFile}";
      };
    };

    # Force Firefox through the local DoH endpoint (needs programs.firefox.enable = true)
    programs.firefox.policies = {
      DNSOverHTTPS = {
        Enabled = true;
        ProviderURL = dohUrl;
        Locked = !hostSpec.distractions;
        # true: mode 2 (fall back to system DNS); false: mode 3 (DoH only)
        Fallback = hostSpec.distractions;
      };
      Certificates.Install = [ caFile ];
    };

    # Manual bypass
    environment.systemPackages = lib.optional hostSpec.distractions (
      pkgs.writeShellApplication {
        name = "dnscrypt-bypass";
        runtimeInputs = [
          config.systemd.package
          config.networking.resolvconf.package
        ];
        text = ''
          [ "$(id -u)" -eq 0 ] || { echo "run with sudo" >&2; exit 1; }
          case "''${1:-}" in
            on)
              systemctl stop dnscrypt-proxy.service
              rm -f /etc/resolv.conf
              printf '%s' ${lib.escapeShellArg bypassResolvConf} > /etc/resolv.conf
              echo "dnscrypt-proxy bypassed (restart Firefox)"
              ;;
            off)
              systemctl start dnscrypt-proxy.service
              resolvconf -u
              echo "dnscrypt-proxy restored"
              ;;
            *)
              echo "usage: sudo dnscrypt-bypass on|off" >&2
              exit 1
              ;;
          esac
        '';
      }
    );
  };
}
