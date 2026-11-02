{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.common.firefox;
  inherit (lib) mkEnableOption mkIf;
  inherit (config) hostSpec;
in
{

  options.common.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = 1; # force KDE Filepicker
      };
    };
  };
}
