{
  config,
  pkgs,
  inputs,
  lib,
  customLib,
  ...
}:
let
  inherit (lib) mkOption mkDefault types;
  inherit (config) hostSpec;
in
{
  imports = customLib.importFolders ./.;

  options.hostSpec = {
    headless = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether this host environment is headless.
        Headless hosts dont have any IO, only network access.
      '';
    };
    distractions = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable distractions in the host environment.";
    };
    hasIPv6Internet = mkOption {
      type = types.bool;
      default = true;
      description = "Wether this device has IPv6 internet.";
    };
  };

  config = {
    common = {
      audio.enable = mkDefault (!hostSpec.headless);
      bluetooth.enable = mkDefault (!hostSpec.headless);
      distractionFreeMode.enable = mkDefault (!hostSpec.headless);
      dnscrypt.enable = mkDefault (!hostSpec.headless);
      firefox.enable = mkDefault (!hostSpec.headless);
      fonts.enable = mkDefault (!hostSpec.headless);
      gaming.enable = mkDefault (!hostSpec.headless && hostSpec.distractions);
      networkmanager.enable = mkDefault (!hostSpec.headless);
      obs.enable = mkDefault (!hostSpec.headless);
      plasma.enable = mkDefault (!hostSpec.headless);
      printing.enable = mkDefault (!hostSpec.headless);
      security.enable = mkDefault true;
      specialisations.enable = mkDefault false; # TODO: Rework and add distraction free mode.
      ventoy.enable = mkDefault (!hostSpec.headless);
      virtualisation.enable = mkDefault false;
      yubikey.enable = mkDefault (!hostSpec.headless);
      zsa.enable = mkDefault (!hostSpec.headless);
    };

    services = {
      flatpak.enable = mkDefault (!hostSpec.headless); # Enables Flatpak
      teamviewer.enable = mkDefault (!hostSpec.headless); # Remote Desktop
      tailscale = {
        enable = mkDefault false;
        openFirewall = true;
      };
    };

    programs = {
      ausweisapp = {
        # Install German AusweisApp2 and open Firewall, so my phone can act as a card reader
        enable = mkDefault (!hostSpec.headless);
        openFirewall = mkDefault true;
      };
      localsend = {
        enable = mkDefault (!hostSpec.headless);
        openFirewall = true;
      };
      appimage = {
        enable = mkDefault true;
        binfmt = mkDefault true;
      };
    };
  };
}
