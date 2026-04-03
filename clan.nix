{
  # Ensure this is unique among all clans you want to use.
  meta.name = "ArgoII";
  meta.domain = "argo2.xaver106.de";

  inventory.machines = {
    iris-vps01 = {
      deploy.targetHost = "root@78.46.239.83";
      tags = [ "server" ];
    };
  };

  secrets.age.plugins = [
    "age-plugin-yubikey"
  ];

  vars.settings = {
    secretStore = "age";
    recipients.default = [
      "age1yubikey1qfrh49yvepx0vn7twhwpjqesfq5zqkum6lmy2ydaj2xympg0dramvt5yxgy" # Yubikey
      "age1yubikey1qvdwrmcxlqmh27eltkufxthh9lzv3gykr6qx76m8jd004dyl8r38yx8zzcn" # Backup Yubikey
    ];
  };

  

  # Docs: See https://docs.clan.lol/latest/services/definition/
  inventory.instances = {

    importer = {
      module.name = "importer";
      roles.default.tags = [ "all" ];
      roles.default.extraModules = [
        ./common
      ];
    };

    # Docs: https://docs.clan.lol/latest/services/official/sshd/
    # SSH service for secure remote access to machines.
    # Generates persistent host keys and configures authorized keys.
    sshd = {
      roles.server.tags.all = { };
      roles.server.settings.authorizedKeys = {
        # Insert the public key that you want to use for SSH access.
        # All keys will have ssh access to all machines ("tags.all" means 'all machines').
        # Alternatively set 'users.users.root.openssh.authorizedKeys.keys' in each machine
        "1Password" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBlG2On4t+CXVgkvgdTsMkDLH/tCDLUL7QtnFJGwkCnP";
        "Yubikey" = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMtwoZrnYD5TiN9WJPPDU6OiyzCX5EIPp7042a1QK+FWAAAABHNzaDo=";
        "YubiKey-Backup" = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMbfHcZ1InSOIUxdkIRNCCdqf+hZ5XA8yJtZFHauFJsiAAAABHNzaDo=";
      };
    };

    # Docs: https://docs.clan.lol/latest/services/official/users/
    # Root password management for all machines.
    user-root = {
      module = {
        name = "users";
      };
      roles.default.tags = [ "server" ];
      roles.default.settings = {
        user = "root";
        prompt = true;
        share = true;
      };
    };

    # Docs: https://docs.clan.lol/latest/services/official/tor/
    # Tor network provides secure, anonymous connections to your machines
    # All machines will be accessible via Tor as a fallback connection method
    tor = {
      roles.server.tags.nixos = { };
    };
  };

  # Additional NixOS configuration can be added here.
  # machines/server/configuration.nix will be automatically imported.
  # See: https://docs.clan.lol/latest/guides/inventory/autoincludes/
  machines = {
    # server = { config, ... }: {
    #   environment.systemPackages = [ pkgs.asciinema ];
    # };
  };
}
