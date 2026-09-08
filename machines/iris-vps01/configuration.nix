{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./mumble-server.nix
    ./acme.nix
    ./matrix.nix
  ];

  config = {
    assertions = [
      {
        assertion = lib.length config.hardware.facter.detected.dhcp.interfaces == 1;
        message = "Multiple or no network detected.";
      }
    ];

    # Check https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud
    systemd.network.enable = true;
    systemd.network.networks."30-wan" = {
      matchConfig.Name = lib.lists.head config.hardware.facter.detected.dhcp.interfaces;
      networkConfig.DHCP = "ipv4";
      address = [
        # replace this subnet with the one assigned to your instance
        "2a01:4f8:1c18:e18a::/64"
      ];
      routes = [
        { Gateway = "fe80::1"; }
      ];
    };

  };
}
