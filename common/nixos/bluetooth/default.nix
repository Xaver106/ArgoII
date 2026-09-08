{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.bluetooth;
in
{

  options.common.bluetooth = {
    enable = mkEnableOption "bluetooth";
  };

  config = mkIf cfg.enable {
    # Enable Bluetoth, obviously...
    hardware.bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };
  };
}
