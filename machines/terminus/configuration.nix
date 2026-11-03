{
  config,
  lib,
  ...
}:
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
        ""
      ];
      routes = [
        { Gateway = "fe80::1"; }
      ];
    };

  };
}
