{
  config,
  pkgs,
  inputs,
  ...
}:
{

  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
    ./hardware-configuration.nix
    ./nvidia.nix
    ./secure-boot.nix
  ];

  networking.hostName = "bunker9";
  hostSpec = {
    headless = false;
    distractions = true;
  };

  nix = {
    # Limit builds from hogging all recources
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;

    settings = {
      # Limit nix build to 8 cores
      cores = 4; # cores per build job
      max-jobs = 3; # parallel builds
    };
  };
  
  # Bootloader.
  boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot = {
        enable = true; # NOTE: Overidden by secure-boot.nix (Kept as backup)
        editor = false;
        edk2-uefi-shell.enable = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  programs.streamcontroller.enable = true;
  programs.streamcontroller.package = pkgs.streamcontroller;

}
