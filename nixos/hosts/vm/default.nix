{
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./vmware.nix
    ./desktops/cosmic.nix
    ./desktops/hyprland.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics.enable = true;

  networking.hostName = "dev";

  # docker in rootless mode on guest machine
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  # Don't require password for sudo
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

  programs.niri.enable = true;
  programs.dconf.enable = true;

  programs.fish.enable = true;
  programs.ssh.startAgent = false; # true in minimal headless setup
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
  # to advertise hostname.local and allow ssh alex@dev.local
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.addresses = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    helix
    wget
    git
    # exploration
    noctalia
    adw-gtk3
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
