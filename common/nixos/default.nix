{
  config,
  pkgs,
  inputs,
  lib,
  customLib,
  ...
}:
let
  inherit (lib) mkOption mkDefault types;
  inherit (config) hostSpec;
in
{
  imports = customLib.importFolders ./.;

  options.hostSpec = {
    headless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether this host environment is headless.
        Headless hosts dont have any IO, only network access.
      '';
    };
    distractions = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable distractions in the host environment.";
    };
  };

  config = {
    common = {
      audio.enable = mkDefault (!hostSpec.headless);
      bluetooth.enable = mkDefault (!hostSpec.headless);
      dev.enable = mkDefault (!hostSpec.headless);
      firefox.enable = mkDefault (!hostSpec.headless);
      fonts.enable = mkDefault true;
      gaming.enable = mkDefault (!hostSpec.headless && hostSpec.distractions);
      networking.enable = mkDefault (!hostSpec.headless); # TODO: Move Networking to machines.
      obs.enable = mkDefault (!hostSpec.headless);
      plasma.enable = mkDefault (!hostSpec.headless);
      printing.enable = mkDefault (!hostSpec.headless);
      security.enable = mkDefault true;
      specialisations.enable = mkDefault false; # TODO: Rework
      ventoy.enable = mkDefault (!hostSpec.headless);
      virtualisation.enable = mkDefault false;
      yubikey.enable = mkDefault (!hostSpec.headless);
      zsa.enable = mkDefault (!hostSpec.headless);
    };
  };
}