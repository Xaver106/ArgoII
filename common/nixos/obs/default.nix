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
      enableVirtualCamera = false; # NOTE: Currently broken: https://github.com/NixOS/nixpkgs/pull/577221
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

  };
}
