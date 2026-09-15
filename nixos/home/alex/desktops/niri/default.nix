{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:

{
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config"
      {
        nativeBuildInputs = [ osConfig.programs.niri.package ];
      }
      ''
        # Validate with a snapshot; Noctalia owns the live color file.
        cp ${./config.kdl} config.kdl
        cp ${./validation/noctalia.kdl} noctalia.kdl

        niri validate --config config.kdl
        cp config.kdl "$out"
      '';

  home.activation.seedNiriColors = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    colorFile=${lib.escapeShellArg "${config.xdg.configHome}/niri/noctalia.kdl"}
    if [ ! -e "$colorFile" ] && [ ! -L "$colorFile" ]; then
      run install -D -m 600 ${./validation/noctalia.kdl} "$colorFile"
    fi
  '';
}
