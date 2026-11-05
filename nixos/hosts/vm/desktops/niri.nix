{ lib, pkgs, inputs, ... }:

let
  theme = import ../../../theme;
  display = import ../display.nix;
  c = theme.colors;
  greeter = pkgs.writeShellScript "niri-regreet" ''
    ${lib.getExe pkgs.regreet}
    ${lib.getExe pkgs.niri} msg action quit --skip-confirmation
  '';
  greeterConfigText = pkgs.writeText "niri-greeter-source.kdl" ''
    hotkey-overlay { skip-at-startup; }
    output "${display.output}" { scale ${display.scale}; }
    spawn-at-startup "${greeter}"
  '';
  greeterConfig = pkgs.runCommand "niri-greeter.kdl" { nativeBuildInputs = [ pkgs.niri ]; } ''
    niri validate --config ${greeterConfigText}
    cp ${greeterConfigText} "$out"
  '';
in
{
  programs.niri.enable = true;
  security.pam.services.veila = { };
  environment.systemPackages = [ inputs.hokum.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  services.dbus.packages = [ inputs.hokum.packages.${pkgs.stdenv.hostPlatform.system}.default ];
  services.displayManager.regreet.enable = true;
  services.displayManager.regreet = {
    font = { package = pkgs.inter; name = theme.font; size = 16; };
    settings.background = { path = "${theme.wallpaper}"; fit = "Cover"; };
    extraCss = ''
      entry, button, dropdown {
        border-radius: 12px;
        color: #${c.text};
        background: #${c.raised};
        border: 1px solid #${c.border};
      }
      entry:focus { border-color: #${c.accent}; }
    '';
  };
  services.greetd.settings.default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.niri} --config ${greeterConfig}";

  # Preserve existing GTK and Qt application support during the transition.
  programs.dconf.enable = true;
  qt.enable = true;
}
