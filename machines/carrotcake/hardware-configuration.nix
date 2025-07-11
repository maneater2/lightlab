{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    initrd = {
      availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "e1000e"];
      luks = {
        reusePassphrases = true;
	devices = {
          "cryptroot" = {
            device = "/dev/disk/by-id/ata-INTENSO_SSD_AA000000000000000524-part2";
	    allowDiscards = true;
	  };
	  "fun" = {
            device = "/dev/disk/by-id/ata-CT1000BX500SSD1_2512E9B11AD2-part1";
	  };
        };
      };
    };
    kernelModules = [ "kvm-intel" ];
  };

  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=4G" "mode=0755"];
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = ["umask=0077"];
    };
    "/nix" = {
    device = "/dev/disk/by-label/nix";
    fsType = "ext4";
    };
    "/fun" = {
      device = "/dev/disk/by-label/fun";
      fsType = "ext4";
    };
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
