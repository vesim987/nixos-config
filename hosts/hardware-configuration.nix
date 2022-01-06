# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" "i915" "ashmem_linux" "binder_linux" ];
  boot.extraModulePackages = [
    (pkgs.stdenv.mkDerivation rec {
      pname = "anbox-modules";
      version = "2020-06-14-${config.boot.kernelPackages.kernel.version}";

      src = pkgs.fetchFromGitHub {
        owner = "choff";
        repo = "anbox-modules";
        rev = "8148a162755bf5500a07cf41a65a02c8f3eb0af9";
        sha256 = "sha256-5YeKwLP0qdtmWbL6AXluyTmVcmKJJOFcZJ5NxXSSgok=";
      };

      patches = [ ./anbox.patch ];

      nativeBuildInputs =
        config.boot.kernelPackages.kernel.moduleBuildDependencies;

      KERNEL_SRC =
        "${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build";

      buildPhase = ''
        for d in ashmem binder;do
          cd $d
          make
          cd -
        done
      '';

      installPhase = ''
        modDir=$out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/kernel/updates/
        mkdir -p $modDir
        for d in ashmem binder;do
          mv $d/$d*.ko $modDir/.
        done
      '';
    }

    )
  ];
  #nixpkgs.config.allowBroken = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.initrd.luks.devices = {
    lvm = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };

  swapDevices = [{ "device" = "/dev/mapper/vg0-swap"; }];

  fileSystems."/" = {
    device = "/dev/mapper/vg0-root";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/vg0-root";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" ];
  };

  fileSystems."/boot/EFI" = {
    device = "/dev/disk/by-uuid/FFCE-DD9C";
    fsType = "vfat";
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
