{ pkgs, ... }:
let
  hyprland-vmware = pkgs.hyprland.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./hyprland-vmwgfx.patch
    ];
  });
in
{
  programs.hyprland = {
    enable = true;
    package = hyprland-vmware;
    withUWSM = true;
    xwayland.enable = true;
  };
}
