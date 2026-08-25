{
  networking = {
    useDHCP = false; # true in minimal headless setup
    firewall.enable = false;
    # VMware Fusion NAT DNS proxy returns malformed responses to EDNS queries.
    resolvconf.dnsExtensionMechanism = false;
  };

  virtualisation.vmware.guest = {
    enable = true;
    # we have a graphical Wayland descktop even though XServer is disabled
    headless = false;
  };

  # turn off suspend for VM
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  # No physical Bluetooth hardware needed in the VM.
  hardware.bluetooth.enable = false;
}
