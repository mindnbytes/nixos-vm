# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= alex

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options to use
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Bootsrap new VM: only does one thing - installs fresh NixOS with declarative
# configuration provided through flake
vm/fresh:
	# prepare partitions and filesystems, mount, generate config
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
		"
	# copy flake from the host
	rsync -av \
		-e "ssh $(SSH_OPTIONS) -p$(NIXPORT)" \
		"$(MAKEFILE_DIR)/nixos/" \
		root@$(NIXADDR):/mnt/nixos-config/ \
	# copy generated hardware config to our flake and install
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
	    cp /mnt/etc/nixos/hardware-configuration.nix \
		   /mnt/nixos-config/hardware-configuration.nix; \
		nixos-install --flake /mnt/nixos-config#vm --no-root-passwd; \
		reboot || true; \
	"
