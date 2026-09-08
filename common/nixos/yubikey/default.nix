{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.yubikey;
in
{

  options.common.yubikey = {
    enable = mkEnableOption "yubikey support";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      yubikey-manager # Yubikey Manager CLI
      opensc # Set of libraries and utilities to access smart cards NOTE: needed for veracrypt smartcard support
      yubioath-flutter # Yubikey Authenticator
    ];

    # enables the pcscd service and adds udev rules
    programs.yubikey-manager.enable = true;
  };
}
