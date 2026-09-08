{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  # Pick a namespace that fits the module, for example `common` or
  # `programs`, and replace MODULE_NAMESPACE / MODULE_NAME with your values.
  cfg = config.common.dolphin-shred;
in
{
  # Define your options here
  options.common.dolphin-shred = {
    enable = mkEnableOption "dolphin-shred";
  };

  # Apply configuration when enabled
  config = mkIf cfg.enable {
    xdg.dataFile = {
      "shred.desktop" = {
        target = "kio/servicemenus/shred.desktop";
        executable = true;
        text = ''
          [Desktop Entry]
          Type=Service
          MimeType=all/allfiles;
          Actions=Shred

          [Desktop Action Shred]
          Name=Safe Remove
          Icon=edit-delete-shred
          Exec=${pkgs.bash}/bin/bash -c '${pkgs.kdePackages.kdialog}/bin/kdialog --title "Safe Delete" --warningcontinuecancel "Safe Delete: Are you sure?" && shred -u -f -z -n3  "%u"'
        '';
      };
      "shred_folder.desktop" = {
        target = "kio/servicemenus/shred_folder.desktop";
        executable = true;
        text = ''
          [Desktop Entry]
          Type=Service
          MimeType=inode/directory;
          Actions=Shred

          [Desktop Action Shred]
          Name=Safe Folder Remove
          Icon=edit-delete-shred
          Exec=${pkgs.bash}/bin/bash -c '${pkgs.kdePackages.kdialog}/bin/kdialog --title "Safe Delete" --warningcontinuecancel "Safe Delete: Are you sure?" && find "%u" -type f -exec shred -u -f -z -n3 {} \; && rmdir "%u"'
        '';
      };
    };
  };
}
