# Noctalia configuration

Home Manager installs Noctalia and its GTK/Qt theme dependencies, sets the Qt
platform theme, and links the TOML files and custom logo templates here into
`~/.config/noctalia/`. Niri starts Noctalia through its `spawn-at-startup` entry.
System-side Niri, dconf, and Qt support lives in `hosts/vm/desktops/niri.nix`.

`config.toml` is a curated baseline of intentional preferences. When importing
an export, omit inactive widget layouts and round incidental numeric precision.
`nix-logo.toml` registers the three SVG templates for the nix-status plugin;
Noctalia generates the colored logos in `~/.cache/noctalia/`.

## Fresh-machine setup

The baseline references assets installed separately from the flake:

- Wallpaper: `/home/alex/Pictures/cosmos_evn_v1.png`.
- Plugins: `noctalia/wallhaven` and `mindnbytes/nix-status`.
- Community templates: `opencode`, `zed`, `fuzzel`, and `fastfetch`.

Restore the wallpaper or update its paths, and install the plugins and community
templates through Noctalia. The current Fastfetch template also requires an
existing `~/.config/fastfetch/config.jsonc` containing strict JSON; its apply hook
does not support comments or trailing commas.

## Settings and theme ownership

GUI changes are saved to `~/.local/state/noctalia/settings.toml` and override
the baseline. To keep new favorites, run `noctalia config export`, review the
output, merge the desired values here, and rebuild. Keep the logo definitions
in `nix-logo.toml` rather than duplicating them in `config.toml`.

Validate this directory with `noctalia config validate home/alex/desktops/noctalia`
from the flake directory. To reset GUI overrides, stop Noctalia, move its
`settings.toml` aside, and restart it. Rebuilding alone does not reset overrides.
Generated application colors and GUI state remain writable and owned by Noctalia.

The current template ownership is:

| Configuration | Owner |
| --- | --- |
| Noctalia baseline and SVG templates | Home Manager |
| Noctalia GUI overrides, downloaded plugins/templates, and generated logos | Noctalia |
| Niri main config and its color include directive | Home Manager |
| Niri live colors | Seeded once by Home Manager, then updated by Noctalia |
| Zed preferences | Home Manager merges declared settings into Zed's writable settings on activation |
| Zed generated theme (`zed/themes/noctalia.json`) | Noctalia; generating it does not select it—Zed's declared theme is Catppuccin Frappé |
| Starship, Fuzzel, Fastfetch, Ghostty, btop, and GTK/Qt theme integration | Noctalia writes colors and its hooks modify writable application configuration |

Home Manager currently supplies Starship's shell integration without defining
its settings, and installs the other applications in the last row without owning
their configuration files. If adding declarative settings for them later, check
the template's output and apply hook first so each file has a clear owner.

The first activation backs up existing unmanaged files with the flake's `.backup`
suffix; any existing backup at the same path must be moved aside first. Log in
again after moving the Qt environment setting into Home Manager.
