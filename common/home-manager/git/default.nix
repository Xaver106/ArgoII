{
  config,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.git;
in
{
  options.common.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {

    programs.git = {
      enable = true;
      settings.user = {
        name = "Xaver106";
        email = "xaver106@posteo.de";
      };
      signing = {
        key = "C6FA3738B20EAC2D7CCF68DA545F10AE238F7DBD";
        signByDefault = true;
      };
    };

    programs.difftastic = {
      enable = mkDefault true;
      git.enable = mkDefault true;
    };

    programs.lazygit = {
      enable = mkDefault true;
      settings = {
        git.diffRenderers = [
          {
            type = "extDiff";
            command = "difft --color=always --context={{diffContext}}";
          }
        ];
      };
    };

  };
}
