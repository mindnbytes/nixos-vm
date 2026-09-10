# Noctalia configuration

Home Manager installs Noctalia and its GTK/Qt theme dependencies, sets the Qt
platform theme, and links the TOML files and custom logo templates here into
`~/.config/noctalia/`. Niri starts Noctalia through its `spawn-at-startup` entry.
System-side Niri, dconf, and Qt support lives in `hosts/vm/desktops/niri.nix`.

`config.toml` is the baseline exported from the current user settings.
`nix-logo.toml` registers the three SVG templates for the nix-status plugin;
Noctalia generates the colored logos in `~/.cache/noctalia/`.
The wallpaper at the configured path and the enabled plugins/community
templates must also be available on a new machine.

GUI changes are saved to `~/.local/state/noctalia/settings.toml` and override
the baseline. To keep new favorites, run `noctalia config export`, review the
output, merge the desired values here, and rebuild. Keep the logo definitions
in `nix-logo.toml` rather than duplicating them in `config.toml`.

Validate this directory with `noctalia config validate home/alex/desktops/noctalia`
from the flake directory. To reset GUI overrides, stop Noctalia, move its
`settings.toml` aside, and restart it. Rebuilding alone does not reset overrides.
Generated application colors and GUI state remain writable and owned by Noctalia.

The first activation backs up existing unmanaged files with the flake's `.backup`
suffix; any existing backup at the same path must be moved aside first. Log in
again after moving the Qt environment setting into Home Manager.
