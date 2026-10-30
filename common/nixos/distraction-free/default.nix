{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.common.distraction-free;
  inherit (lib) mkEnableOption mkIf mkForce;
in
{

  options.common.distraction-free = {
    enable = mkEnableOption "distraction-free";
  };

  config = mkIf cfg.enable {
    specialisation = {
      "distraction-free".configuration = {
        hostSpec = {
          distractions = mkForce false;
        };
      };
    };
  };
}
