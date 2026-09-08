# Niri configuration

NixOS provides niri through `programs.niri.enable`. Home Manager links
`config.kdl` into `~/.config/niri/config.kdl`.

Edit the main configuration here and rebuild to apply it. The build validates it
with the NixOS-selected niri package and `validation/noctalia.kdl`, a snapshot of
the color include used only for validation. An invalid configuration fails the
build, before activation.

`~/.config/niri/noctalia.kdl` remains writable and owned by Noctalia, so dynamic
theme updates continue to work. Niri resolves the relative include beside the
Home Manager symlink. The live color file is not checked during the build or
activation; on a fresh machine, let Noctalia generate its niri colors before
using the configuration.

On initial activation, the flake's Home Manager backup setting preserves the
old unmanaged main config as `config.kdl.backup`. An existing backup at that
path must be moved aside first.
