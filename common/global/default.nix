{
  imports = [
    ./locale.nix
    ./man.nix
    ./pkgs.nix
  ];

  environment.enableAllTerminfo = true;


  nix = {
    gc = {
      # Enable Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true; # Try to reduce size of nix Store
      experimental-features = [
        "nix-command"
        "flakes"
      ]; # Enable Flakes and the nix Command
      trusted-users = [
        "@wheel"
        "root"
      ];

      trusted-substituters = [
        "https://cache.clan.lol"
        "https://nix-community.cachix.org"
      ];
      
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.clan.lol-1:3KztgSAB5R1M+Dz7vzkBGzXdodizbgLXGXKXlcQLA28="
      ];
    };
  };

}
