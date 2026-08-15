# NixOS on Virtual Machine Config

Inspired by [mitchellh config](https://github.com/mitchellh/nixos-config)

## VM Setup

The choice of VM software (VMware Fusion) is just about stability, reliability, and robust graphics support.

### Manual Steps:

- assumes you have VM software installed
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

This Makefile and configuration are intentionally opinionated. If you clone or fork this repository, update the user, hostname, timezone, and `openssh.authorizedKeys.keys` in `nixos/configuration.nix`; also update the user in `nixos/home.nix`.

Run the bootstrap from your Mac, replacing the address and disk as needed:

```sh
make vm/fresh \
  NIXADDR=192.168.64.10 \
  NIXDISK=/dev/nvme0n1 \
  CONFIRM_ERASE=YES
```

The selected disk will be completely erased. The process is:

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
