# This file is just to blow up the installer closure a bit. It will be
# substituted by what the nixos-generate-config script generates for the
# given target hardware
{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
    intel-speed-select
    nvidiabl
    nvidia_x11
    virtualbox
    virtualboxGuestAdditions
    wireguard
    zfs
  ];
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  nix.maxJobs = lib.mkDefault 4;
  nixpkgs.config.allowUnfree = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
