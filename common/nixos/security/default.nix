{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.common.security;
  inherit (lib) mkEnableOption mkDefault mkIf;
  inherit (config) hostSpec;
in
{
  options.common.security = {
    enable = mkEnableOption "Security packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Encryption Tools
      veracrypt # Disk encryption

      # LUKS
      cryptsetup

      # Certificate Management
      gnupg # GNU Privacy Guard
      gpgme # GnuPG Made Easy
      gpg-tui # Terminal UI for GnuPG

      # Age Encryption
      age # Modern encryption tool with small explicit keys
      age-plugin-yubikey # YubiKey plugin for age

      # Password Generators
      xkcdpass # Generate secure multiword passwords/passphrases, inspired by XKCD
      genpass # Simple yet robust commandline random password generator
    ];

    programs = {
      gnupg.agent.enable = mkDefault true;
      _1password.enable = mkDefault true; # 1Password CLI
      _1password-gui.enable = mkDefault (!hostSpec.headless); # 1Password GUI
    };
  };
}
