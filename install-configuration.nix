{ config, pkgs, lib, ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    git
  ];

  hardware.bluetooth.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true;
  };


  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = true;
  };

  services.sshd.enable = true;

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
