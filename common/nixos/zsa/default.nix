{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.zsa;
in
{

  options.common.zsa = {
    enable = mkEnableOption "ZSA Hardware Support";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      keymapp # Application for ZSA keyboards
    ];

    hardware.keyboard.zsa.enable = true;

  };
}
