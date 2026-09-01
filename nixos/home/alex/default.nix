{ pkgs, ... }:

{
  imports = [
    ./desktops/cosmic.nix
    ./programs
  ];
  home = {
    username = "alex";
    homeDirectory = "/home/alex";
    stateVersion = "26.05";

    packages = with pkgs; [
      ghostty
      fuzzel
      fastfetch
      ripgrep
      fd
      eza
      bat
      btop
      gh
      keepassxc
    ];
  };
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
