{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.specialisations.isolated;
in
{

  options.common.specialisations.isolated = {
    enable = mkEnableOption "Isolated Specialisation";
  };

  config = mkIf cfg.enable {
    specialisation.isolated.configuration = {
      boot.loader.systemd-boot.sortKey = "special_isolated";
      fileSystems."/tmpfs" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "size=3G"
          "mode=777"
          "noswap"
        ];
      };

      common = {
        networking.enable = mkForce false;
        bluetooth.enable = mkForce false;
        printing.enable = mkForce false;
        latex.enable = mkForce false;
        gaming.enable = mkForce false;
      };

      networking = {
        useDHCP = mkForce false;
        interfaces = mkForce { };
        wireless.enable = mkForce false;
        networkmanager.enable = mkForce false;
      };
      systemd.network = {
        enable = mkForce false;
        netdevs = mkForce { };
      };
    };
  };
}
