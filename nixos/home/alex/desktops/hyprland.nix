{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fuzzel
    foot
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # UWSM owns systemd session integration.
    systemd.enable = false;
    package = null;
    portalPackage = null;
  };
}
