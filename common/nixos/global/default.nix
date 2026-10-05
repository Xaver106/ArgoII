{
  config,
  pkgs,
  inputs,
  lib,
  customLib,
  ...
}:
let
  overlays = import ../../../overlays { inherit inputs; };
  inherit (config) hostSpec;
in
{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
    inputs.nur.modules.nixos.default
  ]
  ++ customLib.importFiles ./.;

  nixpkgs.config.allowUnfree = true; # Allow unfree packages 
  nixpkgs.overlays = [
    overlays.master-packages
    overlays.stable-packages
  ];

  environment.enableAllTerminfo = hostSpec.headless;
  users.mutableUsers = false;

  catppuccin = {
    enable = true;
    autoEnable = false;
    tty.enable = true;
    cache.enable = true;
  };

  programs = {
    fish.enable = true; # Fish Shell
    ssh.startAgent = true; # Start SSH Agent on login
  };

  nix = {
    gc = {
      # Enable Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true; # Try to reduce size of nix Store

      # Enable Flakes and the nix Command
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Allow root and admins to use extra caches
      trusted-users = [
        "@wheel"
        "root"
      ];
      # Set default caches
      trusted-substituters = [
        "https://cache.clan.lol"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28="
      ];
    };

    # Nix Path and Registry
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry = {
      self.flake = inputs.self;
      nixpkgs.to = {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = inputs.nixpkgs.rev;
        type = "github";
      };
    };
  };
}
