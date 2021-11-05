# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" "i915" ];
  #boot.extraModulePackages = [ pkgs.linuxPackages_latest.nvidia_x11 ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

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
