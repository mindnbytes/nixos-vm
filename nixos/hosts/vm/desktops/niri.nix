{ ... }:

{
  programs.niri.enable = true;

  # Support Noctalia's GTK and Qt application theming.
  programs.dconf.enable = true;
  qt.enable = true;
}
