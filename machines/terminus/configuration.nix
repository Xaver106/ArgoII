{
  config,
  pkgs,
  lib,
  ...
}:
let
  dawarichDomain = "geo.xaver106.de";
in
{
  imports = [

  ];

  config = {
    assertions = [
      {
        assertion = lib.length config.hardware.facter.detected.dhcp.interfaces == 1;
        message = "Multiple or no network detected.";
      }
    ];

    hostSpec = {
      headless = true;
    };

    # Check https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud
    systemd.network.enable = true;
    systemd.network.networks."30-wan" = {
      matchConfig.Name = lib.lists.head config.hardware.facter.detected.dhcp.interfaces;
      networkConfig.DHCP = "ipv4";
      address = [
        # replace this subnet with the one assigned to your instance
        "2a01:4f8:1c16:9565::/64"
      ];
      routes = [
        { Gateway = "fe80::1"; }
      ];
    };

    services.dawarich = {
      enable = true;
      localDomain = dawarichDomain;
      secretKeyBaseFile = config.clan.core.vars.generators.dawarich.files.secret-key-base.path;
    };

    services.nginx.virtualHosts.${dawarichDomain} = {
      enableACME = true;
      forceSSL = true;
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "admin.acme@xaver106.de";
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    clan.core.vars.generators = {
      dawarich = {
        files.secret-key-base.secret = true;   # encrypted in your clan repo, deployed to /run/secrets
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          openssl rand -hex 64 | tr -d '\n' > $out/secret-key-base
        '';
      };
    };

    # clan.core.postgresql = {
    #   enable = true;
    #   databases.dawarich = {
    #     service = "dawarich";
    #     create.enable = false;
    #     restore.stopOnRestore = [ "dawarich-web.service" ];
    #   };
    # };
    # clan.core.state.dawarich =
    # let
    #   redisCli = "${config.services.redis.package}/bin/redis-cli";
    #   systemctl = "${config.systemd.package}/bin/systemctl";
    # in
    # {
    #   folders = [
    #     "/var/lib/dawarich"
    #     "/var/lib/redis-dawarich"
    #   ];
    #   preBackupScript = lib.mkAfter ''
    #     ${redisCli} -s ${config.services.redis.servers.dawarich.unixSocket} SAVE || true
    #   '';
    #   preRestoreScript = lib.mkAfter ''
    #     ${systemctl} stop dawarich-web.service redis-dawarich.service || true
    #   '';
    #   postRestoreScript = lib.mkAfter ''
    #     ${systemctl} start redis-dawarich.service dawarich-web.service
    #   '';
    # };
  };
}
