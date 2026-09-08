{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.dev;
in
{
  options.common.dev = {
    enable = mkEnableOption "Development packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      devenv # Fast, Declarative, Reproducible, and Composable Developer Environments using nix
      
      # Formatter
      treefmt # one CLI to format the code tree

      # Nix
      nil # Nix LSP
      nixd
      nixfmt # Nix formatter

      # Typst
      typst # Markup-based typesetting
      tinymist # Typst LSP

      # Yaml
      yaml-language-server # Language Server for YAML Files

      # Markdown
      marksman # Language Server for Markdown

      # TOML
      taplo # TOML toolkit
    ];

    programs = {
      # Per directory Development Environment
      direnv.enable = mkDefault true;
    };

  };
}
