{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.mpv;
in
{
  options.common.mpv = {
    enable = mkEnableOption "mpv";
  };

  config = mkIf cfg.enable {

    programs.mpv = {
      enable = true;
      bindings = {
        "[" = "add speed -0.05";
        "]" = "add speed 0.05";
        "{" = "add speed -0.1";
        "}" = "add speed 0.1";
      };
    };

  };
}
