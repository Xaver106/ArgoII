{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # File Operations
    bat # Better cat
    eza # Better ls
    fd # Better find
    unzip # Archive extraction

    # Text Editors
    helix # Modern modal editor

    # Task Runners
    go-task # Task runner

    # Version Control
    git # Version control system

    # Terminal Multiplexers
    zellij # Modern terminal multiplexer

    # Hardware Info
    lshw # List hardware
    inxi # System information
    pciutils # PCI utilities
    fastfetch # System information display

    # File System
    ntfs3g # NTFS support
    exfatprogs
    lvm2

    # Network Tools
    wget # File download

  ];
}
