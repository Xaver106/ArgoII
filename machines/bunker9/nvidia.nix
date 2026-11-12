{
  config,
  lib,
  pkgs,
  ...
}:
{

  # Enable graphics driver in NixOS
  hardware.graphics.enable = true;

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement = {
      enable = true;
      kernelSuspendNotifier = false; # Breaks wakup after sleep
    };
    modesetting.enable = true;
    open = true;
  };
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
