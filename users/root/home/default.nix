{
  config,
  pkgs,
  ...
}:
{
  catppuccin = {
    enable = true;
  };

  programs.fish = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      editor = {
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
      };
      keys.normal = {
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
      };
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" ];
  };

  programs.btop = {
    enable = true;
  };

  home.stateVersion = "25.11";
}