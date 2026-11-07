{
  osConfig,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  theme = import ../../../../theme;
  display = import ../../../../hosts/vm/display.nix;
  c = theme.colors;
  niriConfig = pkgs.writeText "niri-themed.kdl" (lib.replaceStrings
    [ "@focusColor@" "@inactiveColor@" "@outputName@" "@outputScale@" ]
    [ c.accent c.muted display.output display.scale ]
    (builtins.readFile ./config.kdl));
in {
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config"
      {
        nativeBuildInputs = [ osConfig.programs.niri.package ];
      }
      ''
        cp ${niriConfig} config.kdl

        niri validate --config config.kdl
        cp config.kdl "$out"
      '';

  home.packages = [ pkgs.veila ];

  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Woodland wallpaper";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg --image ${theme.wallpaper} --mode fill";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = { font = "${theme.font}:size=12"; width = 48; };
      colors = {
        background = "${c.terminal}ff";
        text = "${c.text}ff";
        match = "${c.accent}ff";
        selection = "${c.selection}ff";
        selection-text = "${c.text}ff";
        selection-match = "${c.accent}ff";
        border = "${c.border}ff";
      };
      border = { width = 1; radius = 16; };
    };
  };

  gtk = {
    enable = true;
    font = { name = theme.font; size = 11; };
    theme.name = "Adwaita";
    iconTheme = { name = "Adwaita"; package = pkgs.adwaita-icon-theme; };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = false;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = false;
  };

  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 28;
    gtk.enable = true;
  };

  xdg.configFile."ghostty/config".text = ''
    font-family = ${theme.monoFont}
    background = #${c.terminal}
    foreground = #${c.text}
    cursor-color = #${c.accent}
    selection-background = #${c.selection}
    selection-foreground = #${c.text}
  '';

  xdg.configFile."veila/config.toml".source = (pkgs.formats.toml { }).generate "veila-config.toml" {
    background = { mode = "file"; path = "${theme.wallpaper}"; dim_strength = 25; };
    weather.enabled = false;
    visuals = {
      clock = { font_family = theme.font; color = "#${c.raised}"; };
      date = { font_family = theme.font; color = "#${c.raised}"; };
      username = { font_family = theme.font; color = "#${c.raised}"; };
      input = {
        font_family = theme.font;
        background_color = "#${c.raised}";
        mask_color = "#${c.text}";
        border_color = "#${c.border}";
      };
      placeholder.color = "#${c.muted}";
      status = {
        rejected_color = "#${c.error}";
        pending_color = "#${c.text}";
        color = "#${c.text}";
      };
      eye.color = "#${c.muted}";
      caps_lock.color = "#${c.muted}";
    };
  };

  systemd.user.services.veilad = {
    Unit = {
      Description = "Veila screen locker daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.veila}/bin/veilad";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.veila-idle = {
    Unit = {
      Description = "Veila idle lock monitor";
      After = [ "graphical-session.target" "veilad.service" ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "veilad.service" ];
    };
    Service = {
      ExecStart = "${pkgs.veila}/bin/veila idle --lock-after=600 --lock-before-sleep";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.polkit-agent = {
    Unit = {
      Description = "Polkit authentication agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.hokum = {
    Unit = {
      Description = "Hokum notification daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${inputs.hokum.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/hokum service";
      Restart = "on-failure";
      RestartPreventExitStatus = 78;
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."hokum/config.kdl".text = ''
    tokens {
        fill "#${c.raised}"
        text "#${c.text}"
        muted "#${c.muted}"
        faint "#${c.muted}"
        accent "#${c.accent}"
        border 1 "#${c.border}"
        radius 16
    }
    modules {
        sound #false
        bluetooth #false
    }
    behaviour {
        appearance "light"
        check-for-updates #false
    }
  '';
}
