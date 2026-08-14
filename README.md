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

- change the root password to "root" (we need it to SSH into the VM; by default, neither the `nixos` nor the `root` user has a password)

```
$ sudo su
$ passwd
# change to root
```

- ensure the Makefile points to the correct disk device; I use `/dev/nvme0n1`
- get your VM's IP address with `ip a`
- set the environment variable on your Mac with `export NIXADDR=<VM IP address>`
- you may want to skim through the Makefile to ensure all variables are set correctly

## Bootstrap VM

Here I want to diverge from Mitchell's two-step bootstrap process and try to make a full fresh install from flake.
Conceptually it looks like the flowchart below. Note, that your flake `system.stateVersion` has to correspond the NixOS installer version.

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

Our user has no password yet and can only ssh into VM now. Do `ssh username@hostname.local` and
set the password with `sudo passwd username`.
