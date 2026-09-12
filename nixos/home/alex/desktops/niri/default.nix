{ osConfig, pkgs, ... }:

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
}
