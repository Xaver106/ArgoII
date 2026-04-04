{
  config,
  pkgs,
  lib,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    murmur
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "admin.acme@xaver106.de";
    certs = {
      "mumble.xaver106.de" = {
        dnsProvider = "hetzner";
        environmentFile = config.clan.core.vars.generators.hetznerApiToken.files."hetznerAPI".path;
        group = config.services.mumble-server.group;
        reloadServices = [ "mumble-server.service" ];
      };
    };
  };

  services.mumble-server = {
    enable = true;
    openFirewall = true;
    superuserPwFile = config.clan.core.vars.generators.mumble-superuser-password.files."password".path;
    useACMEHost = "mumble.xaver106.de";
  };

  clan.core.vars.generators = {
    hetznerApiToken = {
      prompts."token" = {
        description = "Hetzner API Token";
        type = "hidden";
        display = {
          label = "Hetzner API Token";
          required = true;
          helperText = "The API token for Hetzner DNS provider.";
        };
      };
      files."hetznerAPI" = {
        secret = true;
        neededFor = "services";
      };

      script = ''
        echo "HETZNER_API_TOKEN=$(cat "$prompts"/token)" >> "$out"/hetznerAPI
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
