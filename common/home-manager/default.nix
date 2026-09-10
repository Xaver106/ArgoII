{
  config,
  pkgs,
  inputs,
  lib,
  customLib,
  osConfig,
  ...
}:
let
  inherit (lib) mkOption mkDefault types mkIf;
  inherit (config) homeSpec;
in
{
  imports = (customLib.importFiles ./.) ++ (customLib.importFiles ./.);

  options.homeSpec = {
    headless = mkOption {
      type = types.bool;
      default = osConfig.hostSpec.headless;
      description = "Whether this home environment is headless.";
    };
    distractions = mkOption {
      type = types.bool;
      default = osConfig.hostSpec.distractions;
      description = "Whether to enable distractions in the home environment.";
    };
  };

  config = {

    common = {
      zellij.enable = mkDefault true;
      helix.enable = mkDefault true;
      git.enable = mkDefault true;
      mpv.enable = mkDefault (!homeSpec.headless);
      kitty.enable = mkDefault (!homeSpec.headless);
      espanso.enable = mkDefault (!homeSpec.headless);
      dolphin-shred.enable = mkDefault (!homeSpec.headless);
    };

    # Fix wrong cursor on x11 windows
    home.file.".icons/default" = {
      enable = (!homeSpec.headless);
      source =  "${pkgs.kdePackages.breeze}/share/icons/breeze_cursors";
    };

    # === Catppuccin ===
    catppuccin = {
      enable = true;
      autoEnable = true;
    };

    # === Fish Shell ===
    programs.fish = {
      enable = true;
    };

    # === Bat ===
    programs.bat = {
      enable = true;
    };

    # === fzf ===
    programs.fzf = {
      enable = true;
    };

    # === Zoxide ===
    programs.zoxide.enable = true;

    # === EZA ===
    programs.eza = {
      enable = true;
      icons = "auto";
      extraOptions = [ "--group-directories-first" ];
    };

    # === Btop ===
    programs.btop = {
      enable = true;
    };

    # === Devenv ===
    programs.devenv = {
      enable = true;
    };

    home.stateVersion = "26.05";
  };
}
