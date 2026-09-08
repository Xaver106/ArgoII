{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.specialisations;
in
{
  imports = [
    ./isolated.nix
  ];

  options.common.specialisations = {
    enable = mkEnableOption "All packages";
  };

  config.common.specialisations = {
    isolated.enable = mkDefault cfg.enable;
  };

}
