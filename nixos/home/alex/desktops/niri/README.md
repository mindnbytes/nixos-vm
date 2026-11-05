# Niri desktop

NixOS runs Niri for both the ReGreet login and the user session. Home Manager
links `config.kdl` after substituting the shared theme colors and validating it
with the NixOS-selected Niri package. Edit the color tokens in
`nixos/theme/default.nix`, rather than the placeholders in `config.kdl`.
The VM output name and scale live in `nixos/hosts/vm/display.nix` and are shared
with the separate ReGreet compositor session.

Mist & Stone uses `nixos/theme/assets/woodland-river.png` for the user session
(`swaybg`), Veila, and ReGreet. The image is user-provided generated artwork;
confirm the generator's terms permit redistribution before publishing it. The
Nix store makes the shared image readable in the separate greeter session.
Inter, Fuzzel, Ghostty, and Hokum use the shared theme where supported; GTK uses
the light Adwaita theme. Application themes and the preview are not pixel-identical.
Home Manager now manages `~/.config/ghostty/config`, `~/.config/fuzzel/fuzzel.ini`
and `~/.config/veila/config.toml`. Review existing personal files before activation:
the configured Home Manager backup extension is `backup`, and existing backups
may prevent activation. Restore desired personal settings in the Nix modules.

Veila 0.4.4 provides the lock screen. Its `veilad` user service starts with the
graphical session; `veila-idle` locks after 600 seconds. `Super+Alt+L` locks
manually. NixOS configures Veila's PAM service. The VM disables suspend, but the
idle service also requests a lock before sleep. Fuzzel remains available with
`Mod+D` or `Mod+Return`.

Hokum provides notifications; sound, Bluetooth, and update checks are disabled.
Home Manager owns `~/.config/hokum/config.kdl`, so edit this configuration rather
than expecting changes made in Hokum's settings UI to persist. The polkit agent
and Hokum also start with the graphical session.

After the first activation, log out and back in to release Noctalia's existing
notification and authentication agents. Keep an SSH connection available and
verify the user password before testing the lock. Check incorrect and correct
passwords, the manual shortcut, ten-minute idle lock, a polkit prompt, a
notification, Fuzzel, ordinary copy/paste, and a portal file chooser. Check
`systemctl --user --failed` and the `veilad`, `veila-idle`, `polkit-agent`, and
`hokum` user service logs if anything fails. Noctalia's former state and theme
files were moved aside during migration; personal wallpapers remain untouched.

For a theme change, also verify the wallpaper, terminal, launcher and notification,
run `veila check-config` and `hokum check`, and reboot to check ReGreet and login.
Keep SSH available and verify both wrong and correct passwords when testing lock
and login. Check cropping and text contrast at the VM's display scale. A Nix
evaluation on macOS does not replace a Linux VM build and visual/security checks.
