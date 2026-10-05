{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.mumble-server = {
    enable = true;
    package = pkgs.stable.murmur;
    openFirewall = true;
    superuserPwFile = config.clan.core.vars.generators.mumble-superuser-password.files."password".path;
    useACMEHost = "mumble.xaver106.de";
    extraConfigFile = config.clan.core.vars.generators.mumble-server-config-override.files."mumble-server-override.ini".path;
    settings = {
      rememberchannel = false;
    };
  };

  clan.core.vars.generators = {
    mumble-server-config-override = {
      files."mumble-server-override.ini" = {
        neededFor = "services";
        restartUnits = [ "mumble-server.service" ];
        secret = true;
      };
      prompts = {
        "serverPassword" = {
          description = "Mumble Server Password";
          type = "hidden";
          display = {
            label = "Mumble Server Password";
            required = false;
            helperText = "The server password for mumble-server. Leave empty for no password.";
          };
        };
      };

      runtimeInputs = [
        pkgs.coreutils
        pkgs.crudini
      ];

      script = ''
        touch "$out"/mumble-server-override.ini
        crudini --set "$out"/mumble-server-override.ini "" "serverpassword" "$(<"$prompts"/serverPassword)"
      '';
    };
    mumble-superuser-password = {
      prompts."password" = {
        description = "Leave empty for a randomly generated password.";
        type = "hidden";
        display = {
          label = "Mumble Superuser Password";
          required = false;
          helperText = "The superuser password for mumble-server. ";
        };
      };
      files."password" = {
        secret = true;
        neededFor = "services";
        restartUnits = [ "mumble-server.service" ];
      };

      runtimeInputs = [
        pkgs.coreutils
        pkgs.xkcdpass
      ];

      script = ''
        prompt_value=$(cat "$prompts"/password)
        if [[ -n "''${prompt_value-}" ]]; then
          echo "$prompt_value" | tr -d "\n" > "$out"/password
        else
          xkcdpass --numwords 4 --delimiter - --count 1 | tr -d "\n" > "$out"/password
        fi
      '';
    };
  };
}
