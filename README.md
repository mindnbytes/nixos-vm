# NixOS on Virtual Machine Config

Inspired by [mitchellh config](https://github.com/mitchellh/nixos-config)

## VM Setup

The choice of VM software (VMware Fusion) is just about stability, reliability, and robust graphics support.

### Manual Steps:

- assumes you have VM software installed
- **note**: copy/paste between host and guest does not work with Wayland guest desktops
- download the [official NixOS image](https://nixos.org/download.html#nixos-iso) `aarch64` ISO
- start creating a VM from this ISO
- keyboard profile - remove most of the shortcuts
- set up the required amount of CPU and RAM, enable 3D graphics acceleration, and enable Retina resolution
- set up the required amount of storage; I keep NVMe in the advanced settings
- network adapter shared with Mac
- remove audio and camera (if you don't need them)

Still manual steps, but inside the booted VM console:

- set a temporary root password (we need it to SSH into the VM; by default, neither the `nixos` nor the `root` user has a password)

```
$ sudo -i
$ passwd
```

- identify the installation disk with `lsblk`; for my VM, it is `/dev/nvme0n1`
- get your VM's IP address with `ip a`
- you may want to skim through the Makefile before proceeding

## Bootstrap VM

Here I want to diverge from Mitchell's two-step bootstrap process and try to make a full fresh install from a flake.
Conceptually, it looks like the flowchart below. Set `system.stateVersion` to the NixOS release initially installed and do not change it during routine upgrades; it does not need to match the installer ISO.

This Makefile and configuration are intentionally opinionated. If you clone or fork this repository, update the user, hostname, timezone, and `openssh.authorizedKeys.keys` in `nixos/hosts/vm/default.nix`. User configuration lives in `nixos/home/alex/default.nix`, with the Home Manager user wired up in `nixos/flake.nix`. Update the checkout and wallpaper paths in `nixos/home/alex/desktops/noctalia/config.toml` to match your setup.

Run the bootstrap from your Mac, replacing the address and disk as needed:

```sh
make vm/fresh \
  NIXADDR=192.168.64.10 \
  NIXDISK=/dev/nvme0n1 \
  CONFIRM_ERASE=YES
```

The selected disk will be completely erased. The Make target sends `scripts/prepare-vm.sh` to Bash in the live installer to check connectivity, partition, format, mount, and generate the hardware configuration. It then uploads the flake and installs NixOS. The process is:

```
make vm/fresh
 │
 ├── SSH into installer
 │
 ├── partition / format / mount
 │
 ├── nixos-generate-config --root /mnt
 │
 ├── copy my Nix flake into /mnt
 │
 ├── nixos-install --flake ...#vm --no-root-passwd
 │
 ├── reboot
 │
 └── hopefully done!
```

## After the Bootstrap

Our user has no password yet and can initially access the VM only through SSH using a private key matching `openssh.authorizedKeys.keys`. Run `ssh username@hostname.local`, or use `ssh -i /path/to/private-key username@hostname.local` for a non-standard key location, then set the password with `sudo passwd username`. Password SSH remains disabled by this configuration.

### Copy SSH identities

Once SSH access works, run this from the repository on the Mac to copy the SSH configuration and identities used for GitHub, GitLab, and other SSH connections:

```sh
make vm/secret NIXADDR=dev.local
```

`scripts/ssh-files.txt` lists the exact filenames to copy from the Mac's `~/.ssh/` into the VM user's `~/.ssh/`. It contains filenames only; key contents stay outside the repository. Edit the list when adding or removing an identity. Every listed file must exist on the Mac.

The copy follows source symlinks, overwrites listed destination files, and leaves other destination files in place. Destination directories use mode `700` and files use mode `600`. The copied SSH config should use Linux-compatible options and identity paths such as `~/.ssh/id_ed25519_mindnbytes`; preserve the `github-ad.com` alias used by the Git configuration.

### Set up the working checkout

`/nixos-config` is the bootstrap copy. Everyday edits and rebuilds use the Git checkout at `/home/alex/Projects/nixos-vm`, whose flake is in the `nixos/` subdirectory. Noctalia's status plugin also uses this flake directory.

On the VM, as `alex`, clone the repository and copy the installed configuration into it once:

```sh
mkdir -p ~/Projects
git clone https://github.com/mindnbytes/nixos-vm.git ~/Projects/nixos-vm
rsync -rv /nixos-config/ ~/Projects/nixos-vm/nixos/
cd ~/Projects/nixos-vm
git diff -- nixos/
```

This preserves the configuration used for installation, including `nixos/hosts/vm/hardware-configuration.nix` with this VM's generated filesystem UUIDs. Review and commit the imported changes. From this point onward, the checkout is the source of truth; `/nixos-config` is no longer used for rebuilds.

## Everyday workflow

Edit system settings in `nixos/hosts/vm/` and user settings in `nixos/home/alex/`. Stage any new configuration files with `git add` so the Git-backed flake can see them. From the VM's flake directory:

```sh
cd ~/Projects/nixos-vm/nixos
nix flake check --no-build
noctalia config validate home/alex/desktops/noctalia
sudo nixos-rebuild switch --flake .#vm
```

`nix flake check --no-build` checks evaluation; the rebuild also validates Niri's configuration before activation. Home Manager is integrated into the system rebuild. See the desktop READMEs for how Noctalia's writable colors and GUI overrides interact with the checked-in settings.

After verifying the result, review `git diff` and commit the intended changes. To update pinned dependencies, run `nix flake update` in the flake directory, then follow the same validation and rebuild steps and commit `flake.lock`.

Helix and Zed use this VM's working flake at `~/Projects/nixos-vm/nixos` for nixd's package and NixOS/Home Manager option completions, independently of the editor's working directory. These are global editor defaults: other projects also use the VM's completion context unless overridden. If you relocate the checkout, update the path in both editor modules and Noctalia's `config.toml`.

### Copy configuration back to the Mac

From the repository on the Mac:

```sh
make vm/sync NIXADDR=dev.local
git diff -- nixos/
```

`vm/sync` copies the VM's working `~/Projects/nixos-vm/nixos/` directory into the local `nixos/` directory. It overwrites matching files and adds new ones, but does not propagate deletions or copy Git history. Review the diff and `git status`, and apply any intended deletions locally.
