{
  networking = {
    # NetworkManager handles DHCP independently of the selected desktop.
    networkmanager.enable = true;
    useDHCP = false;
    firewall.enable = false;
    # VMware Fusion NAT DNS proxy returns malformed responses to EDNS queries.
    resolvconf.dnsExtensionMechanism = false;
  };

  virtualisation.vmware.guest = {
    enable = true;
    # Wayland still needs graphical guest support with XServer disabled.
    headless = false;
  };

  # Keep the guest running; the host controls VM suspension.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  # No physical Bluetooth hardware needed in the VM.
  hardware.bluetooth.enable = false;
}
