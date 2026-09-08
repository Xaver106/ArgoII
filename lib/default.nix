# Custom library functions for NixOS configuration
{ lib }:
rec {
  # Import only subdirectories; each subdirectory is expected to contain a default.nix
  importFolders =
    dir:
    let
      entries = builtins.readDir dir;
      dirs = lib.filterAttrs (_: type: type == "directory") entries;
    in
    map (name: dir + "/${name}") (builtins.attrNames dirs);

  # Recursively import all .nix files in a directory tree, excluding default.nix
  importFiles =
    dir:
    let
      getDir =
        currentDir:
        lib.mapAttrs (file: type: if type == "directory" then getDir "${currentDir}/${file}" else type) (
          builtins.readDir currentDir
        );

      files =
        currentDir:
        lib.collect lib.isString (
          lib.mapAttrsRecursive (path: _: lib.concatStringsSep "/" path) (getDir currentDir)
        );
    in
    map (file: dir + "/${file}") (
      lib.filter (file: lib.hasSuffix ".nix" file && file != "default.nix") (
        files (builtins.toString dir)
      )
    );
}
