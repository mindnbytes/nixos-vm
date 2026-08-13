# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= alex
NIXNAME ?= vm-aarch64

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Bootsrap new VM
vm/fresh:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/nvme0n1 -- mklabel gpt; \
		parted /dev/nvme0n1 -- mkpart root ext4 512MB -8GB; \
		parted /dev/nvme0n1 -- mkpart swap linux-swap -8GB 100\%; \
		parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/nvme0n1 -- set 3 esp on; \
		sleep 2; \
		mkfs.ext4 -L nixos /dev/nvme0n1p1; \
		mkswap -L swap /dev/nvme0n1p2; \
		mkfs.fat -F 32 -n boot /dev/nvme0n1p3; \
		sleep 2; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount -o umask=077 /dev/disk/by-label/boot /mnt/boot; \
		swapon /dev/nvme0n1p2; \
		nixos-generate-config --root /mnt; \
