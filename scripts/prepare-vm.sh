#!/usr/bin/env bash
# Run in the live installer via make vm/fresh. Erases the supplied disk.
set -euo pipefail

disk=${1:?Specify the installation disk}
test -b "$disk"
lsblk -dn -o TYPE "$disk" | grep -qx disk

# Check installer connectivity before erasing the disk.
if ! getent hosts api.github.com >/dev/null 2>&1; then
  echo "DNS resolution failed; retrying without EDNS0 for the installer."
  cp /etc/resolv.conf /tmp/resolv.conf.before-vm-fresh
  sed '/^[[:space:]]*options[[:space:]].*edns0/d' \
    /etc/resolv.conf > /tmp/resolv.conf.vm-fresh
  cat /tmp/resolv.conf.vm-fresh > /etc/resolv.conf
fi
getent hosts api.github.com >/dev/null
getent hosts cache.nixos.org >/dev/null
curl --fail --silent --show-error --location --connect-timeout 15 \
  https://api.github.com/ >/dev/null
curl --fail --silent --show-error --location --connect-timeout 15 \
  https://cache.nixos.org/nix-cache-info >/dev/null

# NVMe and similar disk names need a separator before the partition number.
case "$disk" in
  *[0-9]) partition="${disk}p" ;;
  *) partition="$disk" ;;
esac

parted --script "$disk" -- mklabel gpt
parted --script "$disk" -- mkpart root ext4 512MB -8GB
parted --script "$disk" -- mkpart swap linux-swap -8GB 100%
parted --script "$disk" -- mkpart ESP fat32 1MB 512MB
parted --script "$disk" -- set 3 esp on
udevadm settle --timeout=30
test -b "${partition}1"
test -b "${partition}2"
test -b "${partition}3"

mkfs.ext4 -L nixos "${partition}1"
mkswap -L swap "${partition}2"
mkfs.fat -F 32 -n boot "${partition}3"
udevadm settle --timeout=30

mount "${partition}1" /mnt
mkdir -p /mnt/boot
mount -o umask=077 "${partition}3" /mnt/boot
swapon "${partition}2"
nixos-generate-config --root /mnt
