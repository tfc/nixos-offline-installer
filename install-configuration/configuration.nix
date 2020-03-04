{config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  console.keyMap = "us";

  environment.systemPackages = with pkgs; [
    git
  ];

  i18n.defaultLocale = "en_US.UTF-8";


  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome3.enable = true;
  };

  services.sshd.enable = true;

  time.timeZone = "Europe/Berlin";
}
