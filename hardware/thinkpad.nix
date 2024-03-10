{ config, lib, pkgs, modulesPath, lanzaboote, ... }:

let user-keys = import ../ssh-keys.nix;
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    lanzaboote.nixosModules.lanzaboote
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
    "e1000e"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.network.enable = true;
  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    shell = "/bin/cryptsetup-askpass";
    authorizedKeys = user-keys.tar-xzf ++ user-keys.dettlaff ++ user-keys.cofob
      ++ user-keys.mike;
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/b72c2440-735c-4192-b3fb-bbbd0a794c0a";
      preLVM = true;
    };
  };

  # https://nixos.wiki/wiki/Secure_Boot
  # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.bootspec.enable = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cd6eefbf-3291-4f36-9e30-83ac4ec09926";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s25.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  environment.systemPackages = [ pkgs.sbctl ];
}
