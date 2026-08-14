# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= alex
NIXDISK ?=
CONFIRM_ERASE ?=

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options to use
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Bootsrap new VM: only does one thing - installs fresh NixOS with declarative
# configuration provided through flake
vm/fresh:
	@test -n "$(strip $(NIXDISK))" || { \
		echo "Specify the installation disk, for example NIXDISK=/dev/nvme0n1"; \
		exit 1; \
	}
	@test "$(CONFIRM_ERASE)" = "YES" || { \
		echo "Refusing to erase $(NIXDISK). Re-run with CONFIRM_ERASE=YES"; \
		exit 1; \
	}
	# prepare partitions and filesystems, mount, generate config
	@echo "Connecting to prepare and ERASE $(NIXDISK); enter the live installer root password."
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		set -eu; \
		DISK='$(NIXDISK)'; \
		test -b \"\$$DISK\"; \
		lsblk -dn -o TYPE \"\$$DISK\" | grep -qx disk; \
		case \"\$$DISK\" in \
			*[0-9]) PART=\"\$${DISK}p\" ;; \
			*) PART=\"\$$DISK\" ;; \
		esac; \
		parted --script \"\$$DISK\" mklabel gpt; \
		parted --script \"\$$DISK\" mkpart root ext4 512MB -8GB; \
		parted --script \"\$$DISK\" mkpart swap linux-swap -8GB 100\%; \
		parted --script \"\$$DISK\" mkpart ESP fat32 1MB 512MB; \
		parted --script \"\$$DISK\" set 3 esp on; \
		sleep 2; \
		test -b \"\$${PART}1\"; \
		test -b \"\$${PART}2\"; \
		test -b \"\$${PART}3\"; \
		mkfs.ext4 -L nixos \"\$${PART}1\"; \
		mkswap -L swap \"\$${PART}2\"; \
		mkfs.fat -F 32 -n boot \"\$${PART}3\"; \
		sleep 2; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount -o umask=077 /dev/disk/by-label/boot /mnt/boot; \
		swapon \"\$${PART}2\"; \
		nixos-generate-config --root /mnt; \
		"
	# copy flake from the host
	@echo "Uploading the NixOS configuration; enter the live installer root password again."
	rsync -av \
		-e "ssh $(SSH_OPTIONS) -p$(NIXPORT)" \
		"$(MAKEFILE_DIR)/nixos/" \
		root@$(NIXADDR):/mnt/nixos-config/
	# copy generated hardware config to our flake and install
	@echo "Starting the installation; enter the live installer root password one final time."
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		set -eu; \
		cp /mnt/etc/nixos/hardware-configuration.nix \
		   /mnt/nixos-config/hardware-configuration.nix; \
		nixos-install --flake /mnt/nixos-config#vm --no-root-passwd; \
		sync; \
		systemctl reboot --no-block; \
	"
