{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
  cfg = config.services.mumble-server;
  settingsFormat = pkgs.formats.iniWithGlobalSection { };
  configFile = settingsFormat.generate "mumble-server.ini" {
    sections.Ice = cfg.iceSettings;
    globalSection = cfg.settings;
  };
  acmeHostDir =
  lib.optionalString (cfg.useACMEHost != null)
    config.security.acme.certs."${cfg.useACMEHost}".directory;
in
{
  options = {
    services.mumble-server = {
      enable = lib.mkEnableOption "Mumble server";
      openFirewall = lib.mkEnableOption "opening ports in the firewall for the Mumble server";
      package = lib.mkPackageOption pkgs "murmur" { };

      user = mkOption {
        type = types.str;
        default = "mumble-server";
        description = ''
          The name of an existing user to use to run the service.
          If not specified, the default user will be created.
        '';
      };
      group = mkOption {
        type = types.str;
        default = "mumble-server";
        description = ''
          The name of an existing group to use to run the service.
          If not specified, the default group will be created.
        '';
      };

      useACMEHost = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "mumble.example.com";
        description = ''
          Host of an existing Let's Encrypt certificate to use for TLS.
          Note that this option does not create any certificates and it doesn't add subdomains to existing ones you will need to create them manually using {option}`security.acme.certs`.*
        '';
      };

      stateDir = mkOption {
        type = types.str;
        default = "mumble-server";
        description = "Name of the systemd state directory under /var/lib. This directory stores the sqlite database and other server state.";
      };

      superuserPwFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Path to a file containing the SuperUser password. The file should contain only the password value (no trailing newline).
          The file is loaded using systemd's LoadCredential's option, thus it should be owned by root.
        '';
      };

      extraConfigFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Path to an INI file containing secret runtime overrides for mumble-server.ini.
          The file is loaded using systemd LoadCredential and merged into the generated config in preStart.
          When the same option appears in both files, values in this override file take precedence.
        '';
      };

      settings = mkOption {
        description = ''
          Global options written to mumble-server.ini.
          Configure [Ice] section keys via services.mumble-server.iceSettings.
          Reference: https://github.com/mumble-voip/mumble/blob/master/auxiliary_files/mumble-server.ini
        '';
        default = { };
        type = types.submodule {
          freeformType = types.attrsOf settingsFormat.lib.types.atom;
          options = {
            database = mkOption {
              type = types.externalPath;
              default = "/var/lib/${cfg.stateDir}/mumble-server.sqlite";
              description = "SQLite database path. Keep this inside the state directory to ensure the service user has write access.";
            };
            ice = mkOption {
              type = types.str;
              default = "tcp -h 127.0.0.1 -p 6502";
              description = "ZeroC Ice endpoint used for remote administration.";
            };
            icesecretwrite = mkOption {
              type = types.str;
              default = "";
              description = "Ice write secret. When empty, write access via Ice is denied.";
            };
            welcometext = mkOption {
              type = types.str;
              default = "<br />Welcome to this server running <b>Mumble</b>.<br />Enjoy your stay!<br />";
              description = "Welcome text shown to clients on connect. HTML is supported if allowhtml is enabled.";
            };
            port = mkOption {
              type = types.port;
              default = 64738;
              description = "Port used for both TCP and UDP sockets.";
            };
            serverpassword = mkOption {
              type = types.str;
              default = "";
              description = "Server password required for clients to join when non-empty. Secrets should be passed in via extraConfigFile!";
            };
            bandwidth = mkOption {
              type = types.int;
              default = 558000;
              description = "Maximum client voice bandwidth in bits per second.";
            };
            users = mkOption {
              type = types.int;
              default = 100;
              description = "Maximum number of concurrent clients.";
            };
            messageburst = mkOption {
              type = types.int;
              default = 5;
              description = "Per-user message rate-limit burst size.";
            };
            messagelimit = mkOption {
              type = types.int;
              default = 1;
              description = "Per-user sustained message rate limit in messages per second.";
            };
            allowping = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to respond to UDP ping packets. Exposes user count, max users, and max bandwidth to unauthenticated users.";
            };
            obfuscate = mkOption {
              type = types.bool;
              default = false;
              description = "Obfuscate connecting users' IP addresses in log files. This does not affect the user information view in clients.";
            };
            sslCert = mkOption {
              type = types.nullOr types.str;
              default = if (cfg.useACMEHost != null) then "${acmeHostDir}/fullchain.pem" else null;
              description = "Path to TLS certificate. This option is required to enable TLS. Uses the ACMEHost files by default.";
            };
            sslKey = mkOption {
              type = types.nullOr types.str;
              default = if (cfg.useACMEHost != null) then "${acmeHostDir}/key.pem" else null;
              description = "Path to TLS private key. This option is required to enable TLS. Uses the ACMEHost files by default.";
            };
          };
        };
      };
      iceSettings = mkOption {
        description = "Options written to the [Ice] section of mumble-server.ini.";
        default = { };
        type = types.submodule {
          freeformType = types.attrsOf settingsFormat.lib.types.atom;
          options = {
            "Ice.Warn.UnknownProperties" = mkOption {
              type = types.int;
              default = 1;
              description = "Ice runtime option controlling warnings for unknown properties. See ZeroC Ice documentation.";
            };
            "Ice.MessageSizeMax" = mkOption {
              type = types.int;
              default = 65536;
              description = "Ice runtime option for maximum message size. See ZeroC Ice documentation.";
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.settings.port ];
      allowedUDPPorts = [ cfg.settings.port ];
    };

    users.users = lib.optionalAttrs (cfg.user == "mumble-server") {
      mumble-server = {
        description = "Mumble-server Service user";
        isSystemUser = true;
        group = cfg.group;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == "mumble-server") { mumble-server = { }; };

    systemd.services.mumble-server = {
      description = "Mumble server";
      documentation = [ "man:mumble-server(1)" ];
      after = [ "network.target" ];
      wants = [ "network-online.target" ];
      preStart = ''
        install -Dm600 ${configFile} ''${RUNTIME_DIRECTORY}/mumble-server-runtime.ini
      ''
      + lib.optionalString (cfg.extraConfigFile != null) ''
        ${lib.getExe pkgs.crudini} --merge ''${RUNTIME_DIRECTORY}/mumble-server-runtime.ini < ''${CREDENTIALS_DIRECTORY}/mumble-server-extraConfig.ini
      ''
      + lib.optionalString (cfg.superuserPwFile != null) ''
        ${lib.getExe cfg.package} -ini ''${RUNTIME_DIRECTORY}/mumble-server-runtime.ini -fg -supw "$(<''${CREDENTIALS_DIRECTORY}/mumble-superuser-password)"
      '';
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} -ini \${RUNTIME_DIRECTORY}/mumble-server-runtime.ini -fg";
        ExecReload = "kill -s SIGUSR1 $MAINPID";
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";

        RuntimeDirectory = "mumble-server";
        StateDirectory = cfg.stateDir;

        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "~AF_PACKET" ];
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        ProtectProc = "invisible";
        PrivateMounts = true;
        PrivateUsers = true;
        LoadCredential =
          (lib.optionals (cfg.superuserPwFile != null) [ "mumble-superuser-password:${cfg.superuserPwFile}" ])
          ++ (lib.optionals (cfg.extraConfigFile != null) [ "mumble-server-extraConfig.ini:${cfg.extraConfigFile}" ]);
      };
    };
  };
}
