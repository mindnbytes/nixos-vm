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
	@echo "Connecting to prepare and ERASE $(NIXDISK); enter the live installer root password.";
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		set -eu; \
		DISK='$(NIXDISK)'; \
		test -b \"\$$DISK\"; \
		lsblk -dn -o TYPE \"\$$DISK\" | grep -qx disk; \
		if ! getent hosts api.github.com >/dev/null 2>&1; then \
			echo \"DNS resolution failed; retrying without EDNS0 for the installer.\"; \
			cp /etc/resolv.conf /tmp/resolv.conf.before-vm-fresh; \
			sed '/^[[:space:]]*options[[:space:]].*edns0/d' \
				/etc/resolv.conf > /tmp/resolv.conf.vm-fresh; \
			cat /tmp/resolv.conf.vm-fresh > /etc/resolv.conf; \
		fi; \
		getent hosts api.github.com >/dev/null; \
		getent hosts cache.nixos.org >/dev/null; \
		curl --fail --silent --show-error --location --connect-timeout 15 \
			https://api.github.com/ >/dev/null; \
		curl --fail --silent --show-error --location --connect-timeout 15 \
			https://cache.nixos.org/nix-cache-info >/dev/null; \
		case \"\$$DISK\" in \
			*[0-9]) PART=\"\$${DISK}p\" ;; \
			*) PART=\"\$$DISK\" ;; \
		esac; \
		parted --script \"\$$DISK\" -- mklabel gpt; \
		parted --script \"\$$DISK\" -- mkpart root ext4 512MB -8GB; \
		parted --script \"\$$DISK\" -- mkpart swap linux-swap -8GB 100\%; \
		parted --script \"\$$DISK\" -- mkpart ESP fat32 1MB 512MB; \
		parted --script \"\$$DISK\" -- set 3 esp on; \
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
	@echo "Uploading the NixOS configuration; enter the live installer root password again.";
	rsync -av \
		-e "ssh $(SSH_OPTIONS) -p$(NIXPORT)" \
		"$(MAKEFILE_DIR)/nixos/" \
		root@$(NIXADDR):/mnt/nixos-config/
	# copy generated hardware config to our flake and install
	@echo "Starting the installation; enter the live installer root password one final time.";
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		set -eu; \
		cp /mnt/etc/nixos/hardware-configuration.nix \
		   /mnt/nixos-config/hardware-configuration.nix; \
		nixos-install --flake /mnt/nixos-config#vm --no-root-passwd; \
		sync; \
		systemctl reboot --no-block; \
	"

# Copy common SSH identity material from the host to the installed VM user.
# Requires ordinary host SSH access to work first, for example:
# ssh -p 22 alex@dev.local
# SSH will use a default ~/.ssh/id_* key, or an IdentityFile configured for
# the VM host in ~/.ssh/config.
vm/secret:
	@test "$(NIXADDR)" != "unset" || { \
		echo "Specify the VM address, for example NIXADDR=dev.local"; \
		exit 1; \
	}
	@echo "Copying SSH keys and configuration to $(NIXUSER)@$(NIXADDR)";
	ssh -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) \
		"install -d -m 700 /home/$(NIXUSER)/.ssh"
	rsync -avL \
		--include="/config" \
		--include="/known_hosts" \
		--include="/id_*" \
		--include="/*.pem" \
		--include="/*.key" \
		--exclude="*" \
		-e "ssh -p$(NIXPORT)" \
		"$(HOME)/.ssh/" \
		"$(NIXUSER)@$(NIXADDR):.ssh/"

# Sync VM's latest state nixos-config to this repo
vm/sync:
	@test "$(NIXADDR)" != "unset" || { \
		echo "Specify the VM address, for example NIXADDR=dev.local"; \
		exit 1; \
	}
	@echo "Copying NixOS configuration from $(NIXUSER)@$(NIXADDR)";
	rsync -av \
		-e "ssh -p$(NIXPORT)" \
		"$(NIXUSER)@$(NIXADDR):/nixos-config/" \
		"$(MAKEFILE_DIR)/nixos/"
