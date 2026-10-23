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
    kitty.terminfo # Install Kitty Terminfo on all machines

    # Hardware Info
    lshw # List hardware
    inxi # System information
    pciutils # PCI utilities
    fastfetch # System information display

    # File System
    ntfs3g # NTFS support
    exfatprogs
    lvm2
    compsize # Find compression type/ratio on a file or set of files in the Btrfs filesystem

    # Network Tools
    wget # File download

    # Nix tools
    nix-tree
    nix-sweep
    nvd
  ];
}
