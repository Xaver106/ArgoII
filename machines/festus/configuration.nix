{
  config,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # NOTE: Currently broken. https://github.com/NixOS/nixpkgs/pull/575818
    # inputs.nixos-hardware.nixosModules.framework-11th-gen-intel
  ];

  networking.hostName = "festus";
  hostSpec = {
    headless = false;
    distractions = true;
  };

  common.virtualisation.enable = true;

  environment.systemPackages = with pkgs; [
    framework-tool
    framework-tool-tui
  ];
  services.fwupd.enable = true;

  security.pam.services.login.fprintAuth = false; # Disable fingerprint login (Kwallet doesn't unlock with it)
  
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandlePowerKey = "hibernate";
    HandlePowerKeyLongPress = "poweroff";
  };

  boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        edk2-uefi-shell.enable = false;
      };
      efi.canTouchEfiVariables = true;
    };
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
}
