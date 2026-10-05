{
  config,
  pkgs,
  lib,
  ...
}:
{
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin.acme@xaver106.de";
    certs = {
      "mumble.xaver106.de" = {
        dnsProvider = "hetzner";
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.clan.core.vars.generators.hetznerApiToken.files."hetznerAPI".path;
        group = config.services.mumble-server.group;
        reloadServices = [ "mumble-server.service" ];
      };
    };
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
        echo "HETZNER_API_TOKEN=$(<"$prompts"/token)" >> "$out"/hetznerAPI
      '';
    };
  };
}
