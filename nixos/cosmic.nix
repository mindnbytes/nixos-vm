{ pkgs, pkgsUnstable, ... }:
{
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit (pkgsUnstable)
        cosmic-applets
        cosmic-bg
        cosmic-comp
        cosmic-files
        cosmic-greeter
        cosmic-icons
        cosmic-idle
        cosmic-initial-setup
        cosmic-launcher
        cosmic-notifications
        cosmic-osd
        cosmic-panel
        cosmic-randr
        cosmic-session
        cosmic-settings
        cosmic-settings-daemon
        cosmic-wallpapers
        cosmic-workspaces-epoch
        xdg-desktop-portal-cosmic
        ;

      # Renamed in unstable in July 2026.
      cosmic-applibrary = pkgsUnstable.cosmic-app-library;
    })
  ];

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
    cosmic-player
    cosmic-reader
    cosmic-term
    cosmic-monitor
    cosmic-screenshot
    playerctl
    orca
  ];

  programs.firefox.preferences = {
    # disable libadwaita theming
    "widget.gtk.libadwaita-colors.enabled" = false;
  };

}
