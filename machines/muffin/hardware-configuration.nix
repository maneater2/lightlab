{
  config,
  lib, 
  modulesPath, 
  ... 
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd = {
    availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "iwlwifi" ];
      luks = {
        reusePassphrases = true;
        devices = {
          "cryptroot" = {
            device = "/dev/disk/by-uuid/7c9a3d73-7927-45ae-a29b-f16a6c791bd8";
	    allowDiscards = true;
	  };
	};
      };
    };
  };

  filesystems = {
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
    "nix" = {
      device = "/dev/disk/by-label/Nix";
      fsType = "ext4";
    };
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
