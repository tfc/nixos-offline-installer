{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [ (import <cbspkgs-public/overlay.nix>) ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = with pkgs; [
    git
    cbspkgs.bender
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config = {
    allowUnfree = true;
  };

  time.timeZone = "Europe/Berlin";

  users.extraUsers.tfc = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "audio"
      "dialout"
      "docker"
      "libvirtd"
      "lp"
      "networkmanager"
      "pulse"
      "sound"
      "tty"
      "vboxusers"
      "video"
      "wheel"
    ];
    initialPassword = "lel";
  };
}
