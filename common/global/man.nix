{
  config,
  pkgs,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    # Man Pages + tldr
    man-pages # Implementation of the standard Unix documentation system accessed using the man command
    man-pages-posix # POSIX man-pages (0p, 1p, 3p)
    tldr # Short explanations for commands
  ];

  documentation = {
    dev.enable = true;
  };

}
