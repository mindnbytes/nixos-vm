{ pkgs, ... }:
{
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
}
