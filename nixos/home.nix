{ pkgs, ... }:

{
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  home.packages = with pkgs; [
    fastfetch
    ripgrep
    fd
    eza
    bat
    btop
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./programs/fish.nix
    ./programs/helix.nix
    ./programs/git.nix
  ];
}
