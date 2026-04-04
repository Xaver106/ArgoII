{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./mumble-server.nix
  ];
}
