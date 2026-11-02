{ lib, pkgs, ... }:

let
  greeter = pkgs.writeShellScript "niri-regreet" ''
    ${lib.getExe pkgs.regreet}
    ${lib.getExe pkgs.niri} msg action quit --skip-confirmation
  '';
  greeterConfig = pkgs.writeText "niri-greeter.kdl" ''
    hotkey-overlay { skip-at-startup; }
    spawn-at-startup "${greeter}"
  '';
in
{
  programs.niri.enable = true;
  services.displayManager.regreet.enable = true;
  services.greetd.settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.niri} --config ${greeterConfig}";

  # Support Noctalia's GTK and Qt application theming.
  programs.dconf.enable = true;
  qt.enable = true;
}
