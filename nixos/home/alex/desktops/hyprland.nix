{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fuzzel
    foot
    mako
    libnotify
  ];

  wayland.windowManager.hyprland = {
    enable = true;

    # UWSM owns systemd session integration.
    systemd.enable = false;
    package = null;
    portalPackage = null;
  };

  systemd.user.services.mako-hyprland = {
    Unit = {
      Description = "Mako notification daemon for Hyprland";
      After = [ "wayland-session@hyprland.desktop.target" ];
      PartOf = [ "wayland-session@hyprland.desktop.target" ];
    };

    Service = {
      Type = "exec";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "wayland-session@hyprland.desktop.target" ];
    };
  };

}
