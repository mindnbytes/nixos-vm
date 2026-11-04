{
  osConfig,
  pkgs,
  inputs,
  ...
}:

{
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config"
      {
        nativeBuildInputs = [ osConfig.programs.niri.package ];
      }
      ''
        cp ${./config.kdl} config.kdl

        niri validate --config config.kdl
        cp config.kdl "$out"
      '';

  home.packages = [ pkgs.veila ];

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
    modules {
        sound #false
        bluetooth #false
    }
    behaviour {
        check-for-updates #false
    }
  '';
}
