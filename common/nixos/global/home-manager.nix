{
  config,
  pkgs,
  lib,
  inputs,
  customLib,
  ...
}:
with lib;

{
  # Import Home Manager's NixOS module
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  config.home-manager = {

    # Enable global packages and user packages by default
    useGlobalPkgs = mkDefault true;
    useUserPackages = mkDefault true;
    backupFileExtension = "hm-bak";
    sharedModules = [
      inputs.catppuccin.homeModules.catppuccin
      ../../home-manager
    ];

    # Ensure Home Manager receives `customLib` via extraSpecialArgs.
    # Use `inherit` to pass the variable by name.
    extraSpecialArgs = { inherit customLib; };
  };
}
