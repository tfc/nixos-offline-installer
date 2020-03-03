{config, pkgs, ...}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Berlin";

  services.xserver = {
    enable = true;
    layout = "us";
    xkbOptions = "eurosign:e";
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome3.enable = true;
  };



  #boot.initrd.kernelModules = [ "wl" ];
  #boot.kernelModules = [ "kvm-intel" "wl" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # programs that should be available in the installer
  environment.systemPackages = with pkgs; [
    git
  ];

  services.sshd.enable = true;
}
