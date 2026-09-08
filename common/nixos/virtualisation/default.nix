{
  config,
  pkgs,
  lib,
  ...
}:
with lib;

let
  cfg = config.common.virtualisation;
in
{

  options.common.virtualisation = {
    enable = mkEnableOption "Virtualisation";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      qemu
      quickemu

      # VM imaging tools
      # libguestfs-with-appliance # Tools for accessing and modifying virtual machine disk images
      virtiofsd
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true; # Alow TPM Emulation
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      };
      spiceUSBRedirection.enable = true; # Enable USB Redirection with Spice NOTE: this allows users arbitrary access to USB devices!
      # Android Virtualisation
      waydroid.enable = true;
    };

    # if you use libvirtd on a desktop environment
    programs.virt-manager.enable = true; # can be used to manage non-local hosts as well

  };
}
