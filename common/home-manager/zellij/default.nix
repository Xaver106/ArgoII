{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.zellij;
in
{
  options.common.zellij = {
    enable = mkEnableOption "zellij";
  };

  # Apply configuration when enabled
  config = mkIf cfg.enable {

    # managing the zellij config, breaks the builtin config manager.
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;
      enableFishIntegration = false;
      enableBashIntegration = false;

      settings = {
        mouse_hover_effects = false;
        pane_frame_style = "full";
      };
    };

    xdg.configFile."zellij/layouts" = {
      source = ./Zellij-Layouts;
      recursive = true;
    };
  };
}
