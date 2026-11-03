{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.common.virtualisation;
  inherit (lib) mkIf mkEnableOption mkDefault;
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

      waydroid-helper
    ];

    virtualisation = {
      libvirtd = {
        enable = mkDefault true;
        qemu.swtpm.enable = true; # Alow TPM Emulation
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      };
      spiceUSBRedirection.enable = mkDefault true; # Enable USB Redirection with Spice NOTE: this allows users arbitrary access to USB devices!
      # Android Virtualisation
      waydroid = {
        enable = mkDefault true;
        package = pkgs.waydroid-nftables;
      };
    };

    # if you use libvirtd on a desktop environment
    programs.virt-manager.enable = mkDefault true; # can be used to manage non-local hosts as well

  };
}
