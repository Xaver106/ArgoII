{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.obs;
in
{
  options.common.obs = {
    enable = mkEnableOption "obs";
  };

  config = mkIf cfg.enable {

    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

  };
}
