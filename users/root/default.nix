{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  users.users.root = {
    shell = pkgs.fish;
  };

  programs.fish.enable = true;

  home-manager.users.root = {
    home = {
      username = "root";
      homeDirectory = "/root";
    };
  };
}
