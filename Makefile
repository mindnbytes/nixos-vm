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

.PHONY: vm/fresh vm/secret vm/sync

# Install fresh NixOS from the flake.
vm/fresh:
	@test -n "$(strip $(NIXADDR))" && test "$(NIXADDR)" != "unset" || { \
		echo "Specify the VM address, for example NIXADDR=192.168.64.10"; \
		exit 1; \
	}
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
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) \
		"bash -s -- '$(NIXDISK)'" < "$(MAKEFILE_DIR)/scripts/prepare-vm.sh"
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
		   /mnt/nixos-config/hosts/vm/hardware-configuration.nix; \
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

# Copy the VM's working flake into this repo; does not propagate deletions.
vm/sync:
	@test "$(NIXADDR)" != "unset" || { \
		echo "Specify the VM address, for example NIXADDR=dev.local"; \
		exit 1; \
	}
	@echo "Copying NixOS configuration from $(NIXUSER)@$(NIXADDR)";
	rsync -av \
		-e "ssh -p$(NIXPORT)" \
		"$(NIXUSER)@$(NIXADDR):/home/$(NIXUSER)/Projects/nixos-vm/nixos/" \
		"$(MAKEFILE_DIR)/nixos/"
