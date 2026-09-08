{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.ports;
in
{
  options.common.ports = {
    enable = mkEnableOption "Default port mappings for common programs";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ ];
    networking.firewall.allowedUDPPorts = [ 5901 ]; # reMarkable rmview
  };
}
