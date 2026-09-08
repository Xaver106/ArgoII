{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.kitty;
in
{
  options.common.kitty = {
    enable = mkEnableOption "common kitty configuration";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.name = "IosevkaTerm Nerd Font Mono";
      settings = {
        confirm_os_window_close = 0;
        remember_window_size = false;
      };
    };
  };
}
