# Niri desktop

NixOS runs Niri for both the ReGreet login and the user session. Home Manager
links `config.kdl` after validating it with the NixOS-selected Niri package.
Its colors are static and do not depend on a generated theme file.

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
