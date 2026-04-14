{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  users.users.root = {
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  home-manager.users.root = {
    home = {
      username = "root";
      homeDirectory = "/root";
    };
    imports = [
      ./home
      inputs.catppuccin.homeModules.catppuccin
    ];
  };
}
