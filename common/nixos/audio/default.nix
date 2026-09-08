{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.audio;
in
{

  options.common.audio = {
    enable = mkEnableOption "audio";
  };

  config = mkIf cfg.enable {
    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      crosspipe # PipeWire graph GTK4/Libadwaita GUI
      easyeffects # Audio effects for PipeWire applications
    ];

  };
}
