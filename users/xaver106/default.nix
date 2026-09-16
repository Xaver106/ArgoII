{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (lib) optional;
  inherit (config) hostSpec;
in
{

  # Home Manager is imported and configured centrally in hosts/common/home-manager

  # Define my user account.
  users.users.xaver106 = {
    isNormalUser = true;
    description = "Xaver106";
    shell = pkgs.fish;
    extraGroups = [
      "libvirtd"
      "networkmanager"
      "plugdev"
      "dialout"
      "input"
      "video"
    ] ++ optional hostSpec.distractions "wheel";
    /*
      libvirtd: Virtualisation Authentication access
      networkmanager: Allow user to use networkmanager to manage network connections
      plugdev: Gives access to mount sme devices NOTE: Needed to interact with YubiKeys
      dialout: Full and direct access to serial ports
      input: Allows access to input devices
      video: Allows access to video devices
    */
  };

  # Certain features, including CLI integration and system authentication support,
  # require enabling PolKit integration on some desktop environments (e.g. Plasma).
  programs._1password-gui.polkitPolicyOwners = [ "xaver106" ];

  home-manager.users.xaver106 = {
    home = {
      username = "xaver106";
      homeDirectory = "/home/xaver106";
    };
  };
}
