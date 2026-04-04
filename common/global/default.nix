{
  imports = [
    ./locale.nix
    ./man.nix
    ./pkgs.nix
  ];

  environment.enableAllTerminfo = true;
}