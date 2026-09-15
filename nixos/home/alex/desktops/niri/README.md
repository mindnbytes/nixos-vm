# Niri configuration

NixOS provides niri through `programs.niri.enable`. Home Manager links
`config.kdl` into `~/.config/niri/config.kdl`.

Edit the main configuration here and rebuild to apply it. The build validates it
with the NixOS-selected niri package and `validation/noctalia.kdl`, a snapshot of
the color include also used to seed fresh accounts. An invalid configuration
fails the build, before activation.

`~/.config/niri/noctalia.kdl` remains writable and owned by Noctalia, so dynamic
theme updates continue to work. Niri resolves the relative include beside the
Home Manager symlink. After linking the configuration, Home Manager copies the
snapshot into the live color file only if no file or symlink exists there. The
copy is writable, so Niri can start immediately and Noctalia can update its
colors. Rebuilds preserve existing colors; the live file is not validated.

On initial activation, the flake's Home Manager backup setting preserves the
old unmanaged main config as `config.kdl.backup`. An existing backup at that
path must be moved aside first.
