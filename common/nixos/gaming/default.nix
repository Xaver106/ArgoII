{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.gaming;
in
{
  options.common.gaming = {
    enable = mkEnableOption "Gaming packages";
  };

  config = mkIf cfg.enable {
    # XBOX Controller support
    hardware.xone.enable = true;

    boot.kernelModules = [ "ntsync" ]; # Enable the new ntsync module

    programs = {
      steam = {
        enable = true;
        protontricks.enable = true;
        remotePlay.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        extraCompatPackages = with pkgs; [
          (proton-ge-bin.overrideAttrs { steamDisplayName = "GE-Proton-NixOS"; })
        ];
      };
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      gamemode.enable = true;
      gpu-screen-recorder.enable = true;
    };

    environment.systemPackages = with pkgs; [
      (prismlauncher.override {
      jdks = with pkgs; [
        temurin-jre-bin
        temurin-jre-bin-17
      ];
    })
    mangohud
    protonplus # Proton Manager (GTK)
    protonup-qt # The OG Protonup
    protonup-rs # Rust Proton manager [Github](https://github.com/auyer/Protonup-rs)
    gpu-screen-recorder
    gpu-screen-recorder-gtk
    wowup-cf
    ];
  };
}
