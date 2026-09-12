{ osConfig, pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "quake-toggle";
      runtimeInputs = [ osConfig.programs.niri.package pkgs.ghostty pkgs.jq ];
      text = builtins.readFile ./scripts/quake-toggle;
    })
  ];

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
