# Project decisions

This is a concise record of decisions and their reasons, not a description of
every current setting. Check the source for current behavior. Update an entry
when its decision changes; Git history retains previous versions.

## Direction and scope

- Build a minimal, reliable, attractive Niri desktop for the ARM64 NixOS VM on
  VMware Fusion. Favor correctness and remove unneeded components instead of
  retaining or introducing services just in case.
- Split common and host-specific configuration when a second machine exists,
  rather than prebuilding abstractions. VM and physical hardware may need
  different security and hardware choices.

## Login and desktop

- Run ReGreet in a separate minimal Niri session through greetd. The default
  Cage/wlroots greeter failed on VMware Fusion with a DMA-buffer error and GTK
  disconnect; using the already-tested Niri compositor worked and survived a
  reboot. Do not replace the working greeter solely to unify its appearance with
  the lock screen.
- COSMIC and Noctalia were removed to reduce desktop complexity. Veila provides
  PAM-backed locking with a ten-minute idle timeout; Hokum provides notifications,
  polkit-gnome handles graphical authentication, and Fuzzel is the launcher.
  Ordinary clipboard copy/paste is sufficient; clipboard history and graphical
  audio, network and power controls are not current requirements.
- Keep login and lock visually cohesive where practical. The Mist & Stone theme
  uses a light palette and woodland/water imagery, inspired by selected macOS
  aesthetics rather than an imitation. Shared greeter assets must be readable in
  its separate session. Investigate actual Niri theming support before attempting
  to refine its quit and hotkey overlays; polkit appearance is also future work.
- Fuzzel is acceptable for now. A more Spotlight-like launcher may be explored
  later, with privacy and dependency costs considered.
- Disable only the VMware vmblock mount: host–guest drag-and-drop is not needed
  in this Wayland VM. The generated `fuse` mount failed with the installed FUSE 3
  helper; an isolated `fuse3` mount worked. Keep the main VMware guest service.

## Security, recovery and provisioning

- Plan to enable the VM firewall and open required ports deliberately. Retain
  passwordless sudo in the VM for convenience and the current trusted-local-network
  bootstrap tradeoff unless it can be improved without extra manual steps. These
  are VM choices, not defaults for future physical machines.
- Define recovery after simplifying the desktop; consider Disko when ready to
  test declarative partitioning and full recovery. Preserve SSH private keys and
  configuration, personal wallpapers in `~/Pictures`, and OpenCode local data and
  conversations. Browser profiles, disposable projects and GitHub CLI login are
  not currently required. This scope is not itself a backup.
- Noctalia migration moved affected personal configuration and state to
  `/home/alex/.local/state/noctalia-retired-NnnWoCRC` on the VM and preserved
  personal wallpapers. Check before removing or replacing those recovery files.

## Project reasoning

- Keep durable decisions and their rationale in this repository rather than
  maintaining a separate Entire Brain index. Git and current source remain the
  authority for configuration; this log captures context that code alone cannot.
