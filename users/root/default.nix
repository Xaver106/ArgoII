{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkForce;
in
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
    homeSpec.headless = mkForce true;
  };
}
