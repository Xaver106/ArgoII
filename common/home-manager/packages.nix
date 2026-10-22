{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) optionals;
  inherit (config) homeSpec;
in
{
  home.packages = with pkgs; [
    # CLI only Packages
    
    # Calculators
    programmer-calculator # Terminal calculator for programmers
    bitwise # Terminal based bitwise calculator in curses
    ipcalc # Simple IP network calculator
    kalker # Command line calculator with math functions
    rink # Unit-aware calculator with currency support

    # File Managers
    ranger # Vim-like file manager
    lf # Terminal file manager written in Go and heavily inspired by ranger

    # Shell Utilities
    killall # Process killer
    fzf # Fuzzy finder
    pandoc # Document converter
    unixtools.net-tools # Internet tools

    # System Monitoring
    btop # Resource monitor
    dust # Disk usage analyzer

    # File System
    fdupes # Find duplicate files
    f3 # Fight Flash Fraud

    # Network Tools
    dig # DNS lookup
    cfspeedtest # Internet speed test

  ] ++ optionals (!homeSpec.headless) [ 
    # Desktop
    gparted
    kdePackages.partitionmanager
    kdePackages.filelight
    kdiskmark
    kdePackages.kcharselect
    bottles
    resources
    mission-center
    clapgrep

    # Communication
    signal-desktop
    ferdium
    element-desktop
    vesktop
    mumble
    thunderbird

    # Development
    vscode
    zed-editor
    # jetbrains.idea
    # jetbrains.pycharm
    # jetbrains.goland
    kdePackages.kate
    gittyup
    sqlitebrowser
    textpieces

    # Internet
    tor-browser
    filezilla
    localsend
    nextcloud-client
    rymdport
    rustdesk-flutter
    speedtest

    # Media
    mpv
    haruna
    vlc
    mkvtoolnix
    losslesscut-bin
    # audacity # NOTE: Currently broken: https://github.com/NixOS/nixpkgs/pull/577022
    inkscape
    gimp
    qimgv
    digikam
    switcheroo
    curtail
    converseen
    kdePackages.k3b # Full-featured CD/DVD/Blu-ray burning and ripping application
    stable.soundconverter # Leading audio file converter for the GNOME Desktop
    (pkgs.ffmpeg-full.override { withUnfree = false; })

    # Productivity
    libreoffice-qt
    hunspell
    hunspellDicts.de_DE
    hunspellDicts.en_US
    geogebra6
    speedcrunch
    kdePackages.kalgebra
    kdePackages.kcalc
    qalculate-qt
    ocrmypdf
    tesseract
    qpdf
    kdePackages.klevernotes
    handy # Free, open source, offline speech-to-text application

    # Security
    cryptomator
    veracrypt
    gocryptfs
    sirikali
    kdePackages.kleopatra

    # 3D Printing
    prusa-slicer
    freecad
    blender

    # ReMarkable
    rmview
    remarkable-mouse

    # === Development ===

    # Formatter
    treefmt # one CLI to format the code tree

    # Nix
    nil # Nix LSP
    nixd
    nixfmt # Nix formatter

    # Typst
    typst # Markup-based typesetting
    tinymist # Typst LSP

    # Yaml
    yaml-language-server # Language Server for YAML Files

    # Markdown
    marksman # Language Server for Markdown

    # TOML
    taplo # TOML toolkit

  ] ++ optionals homeSpec.distractions [
    
  ];
}
