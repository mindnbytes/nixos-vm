{ pkgs, ... }:

{
  home.packages = with pkgs; [
    noctalia
    adw-gtk3
    qt6Packages.qt6ct
  ];

  home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";

  xdg.configFile = {
    "noctalia/config.toml".source = ./config.toml;
    "noctalia/nix-logo.toml".source = ./nix-logo.toml;
    "noctalia/templates" = {
      source = ./templates;
      recursive = true;
    };
  };
}
