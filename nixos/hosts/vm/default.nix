{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./vmware.nix
    ./desktops/cosmic.nix
    ./desktops/niri.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics.enable = true;

  networking.hostName = "dev";

  # Allow access from the Mac to development servers without per-port rules.
  networking.firewall.enable = false;

  # Run Docker as the user rather than a system-wide daemon.
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Europe/Berlin";

  users.users.alex = {
    isNormalUser = true;
    home = "/home/alex";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4as7RFWaxXjH10hks+DOaur/5G8LJODtnwQzKQceJk nixos-vm"
    ];
  };

  programs.fish.enable = true;
  programs.ssh.startAgent = false;
  services.xserver.enable = false;

  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      AllowUsers = [ "alex" ];
    };
  };

  # Advertise dev.local for SSH access.
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.addresses = true;
  };

  # Basic tools are also available outside Alex's Home Manager environment.
  environment.systemPackages = with pkgs; [
    helix
    wget
    git
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 10d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  system.stateVersion = "26.05";
}
