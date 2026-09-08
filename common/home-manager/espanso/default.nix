{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.espanso;
in
{
  options.common.espanso = {
    enable = mkEnableOption "espanso";
  };

  config = mkIf cfg.enable {
    services.espanso = {
      enable = true;
      x11Support = false;

      configs = {
        default = {
          show_notifications = false;
          search_shortcut = "CTRL+SHIFT+SPACE";
        };
      };

      matches = {
        base = {
          matches = [
            {
              trigger = ":euro";
              replace  = "€";
            }
          ];
        };
      };
    };
  };
}
