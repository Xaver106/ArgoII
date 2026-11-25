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
        show_startup_tips = false;
        show_setup_screen = false;
        on_quit = "quit";
      };
    };

    xdg.configFile."zellij/layouts" = {
      source = ./Zellij-Layouts;
      recursive = true;
    };
  };
}
