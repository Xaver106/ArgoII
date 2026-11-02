{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.common.distractionFreeMode;
  inherit (lib) mkEnableOption mkIf mkForce;
in
{

  options.common.distractionFreeMode = {
    enable = mkEnableOption "distractionFreeMode";
  };

  config = mkIf cfg.enable {
    specialisation = {
      "distractionFreeMode".configuration = {
        hostSpec = {
          distractions = mkForce false;
        };
      };
    };
  };
}
