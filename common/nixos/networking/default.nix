{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.common.networking;
  inherit (lib) mkEnableOption mkDefault mkIf;
  inherit (config) hostSpec;
in
{

  options.common.networking = {
    enable = mkEnableOption "networking";
  };

  config = mkIf cfg.enable {

    # Enable Networkmanager
    networking.networkmanager.enable = true;

    networking.networkmanager.plugins = with pkgs; [
      networkmanager-openconnect
      networkmanager-openvpn

      # Too niche to install by default
      # networkmanager-fortisslvpn
      # networkmanager-l2tp
      # networkmanager-strongswan
      # networkmanager-vpnc

      # Even more nieche
      # networkmanager-sstp
      # networkmanager-iodine
    ];

    services.tailscale = {
      enable = mkDefault true;
      openFirewall = true;
    };

    programs = {
      localsend = {
        enable = mkDefault (!hostSpec.headless);
        openFirewall = true;
      };
    };
  };
}
