{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  cfg = config.common.ventoy;
in
{
  options.common.ventoy = {
    enable = mkEnableOption "ventoy";
  };

  config = mkIf cfg.enable {

    nixpkgs.config.permittedInsecurePackages = [
      "ventoy-qt5-1.1.17"
    ];

    environment.systemPackages = with pkgs; [
      ventoy-full-qt
    ];
  };
}
