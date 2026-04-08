{
  pkgs,
  config,
  lib,
  ...
}:
{
  services.matrix-tuwunel = {
    enable = true;
    settings.global = {
      port = [ 6167 ];
      allow_federation = false;
      registration_token_file = config.clan.core.vars.generators.tuwunel-registration-token.files.token.path;
      allow_registration = true;
      server_name = "matrix-test.xaver106.de";
      encryption_enabled_by_default_for_room_type = "all";
      auto_join_rooms = [
        "#nd-aachen:matrix-test.xaver106.de"
        "#Ankuendigungen:matrix-test.xaver106.de"
      ];
      new_user_displayname_suffix = "";
      well_known = {
        client = "https://matrix-test.xaver106.de";
        server = "matrix-test.xaver106.de:443";
      };
    };
  };

  services.caddy = {
    enable = true;

    virtualHosts."matrix-test.xaver106.de" = {
      extraConfig = ''
        reverse_proxy localhost:6167
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

  clan.core.vars.generators = {
    tuwunel-registration-token = {
      prompts.token = {
        description = "Leave empty for a randomly generated token.";
        type = "hidden";
        display = {
          label = "Registration Token";
          required = false;
          helperText = "The registration token for Matrix for Matrix Tuwunel Tuwunel. Leave empty for a randomly generated token.";
        };
      };
      files.token = {
        secret = true;
        neededFor = "services";
        restartUnits = [ "tuwunel.service" ];
        owner = config.services.matrix-tuwunel.user;
        group = config.services.matrix-tuwunel.group;
      };

      runtimeInputs = [
        pkgs.coreutils
        pkgs.xkcdpass
      ];
    
      script = ''
        prompt_value=$(cat "$prompts"/token)
        if [[ -n "''${prompt_value-}" ]]; then
          echo "$prompt_value" | tr -d "\n" > "$out"/token
        else
          xkcdpass --numwords 4 --delimiter - --count 1 | tr -d "\n" > "$out"/token
        fi
      '';
    };
  };
}
