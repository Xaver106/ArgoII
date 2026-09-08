{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.fonts;
in
{

  options.common.fonts = {
    enable = mkEnableOption "fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true; # Install some general default fonts
      packages = with pkgs; [
        # Nerdfonts
        nerd-fonts.symbols-only
        nerd-fonts.iosevka
        nerd-fonts.iosevka-term

        # Microsoft Fonts
        corefonts
        vista-fonts
      ];
    };
  };
}
