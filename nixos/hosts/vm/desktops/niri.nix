{ lib, pkgs, inputs, ... }:

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
  security.pam.services.veila = { };
  environment.systemPackages = [ inputs.hokum.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  services.dbus.packages = [ inputs.hokum.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  services.displayManager.regreet.enable = true;
  services.greetd.settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.niri} --config ${greeterConfig}";

  # Preserve existing GTK and Qt application support during the transition.
  programs.dconf.enable = true;
  qt.enable = true;
}
