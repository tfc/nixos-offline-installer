{ installConfigurationPath, installConfiguration }:

{ config, pkgs, lib, ... }:

let
  installConfigurationString = builtins.readFile installConfigurationPath;
  installBuild = installConfiguration.system.build;
in {
  imports = [
    ../nixos/modules/installer/cd-dvd/iso-image.nix
    ../nixos/modules/profiles/all-hardware.nix
    ../nixos/modules/profiles/base.nix
    ../nixos/modules/profiles/installation-device.nix
    ../nixos/modules/installer/cd-dvd/channel.nix
    ../nixos/modules/installer/tools/tools.nix
  ];

  # configure proprietary drivers
  nixpkgs.config.allowUnfree = true;
  #boot.initrd.kernelModules = [ "wl" ];
  #boot.kernelModules = [ "kvm-intel" "wl" ];
  #boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  environment.systemPackages = with pkgs; [
    git
    parted # check if this can be removed
  ];

  system.nixos-generate-config.configuration = installConfigurationString;

  systemd.services.sshd.enable = true;

  isoImage.compressImage = false;
  isoImage.isoBaseName = "nixos-offline-installer";
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.volumeID = "NIXOS_ISO";
  isoImage.storeContents = [ # TODO: Check if the whole storeContents attr is needed
    # Add install-relevant stuff
    #installBuild.nixos-enter # unconfirmed if this is really needed
    #installBuild.nixos-generate-config # unconfirmed if this is really needed
    #installBuild.nixos-install # unconfirmed if this is really needed
    installBuild.toplevel.drvPath
  ];
  isoImage.includeSystemBuildDependencies = true; # unconfirmed if this is really needed

  system.stateVersion = "20.03";

  systemd.services.installer = {
    description = "Unattended NixOS installer";
    wantedBy = [ "multi-user.target" ];
    after = [ "getty.target" "nscd.service" ];
    conflicts = [ "getty@tty1.service" ];
    serviceConfig = {
      Type="oneshot";
      RemainAfterExit="yes";
      StandardInput="tty-force";
      StandardOutput="inherit";
      StandardError="inherit";
      TTYReset="yes";
      TTYVHangup="yes";
    };
    path = [ "/run/current-system/sw" ];
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    script = ''
      set -euxo pipefail

      # If the partitions exist already as-is, parted might error out
      # telling that it can't communicate changes to the kernel...
      wipefs -fa /dev/sda

      # These are the exact steps from
      # https://nixos.org/nixos/manual/index.html#sec-installation-summary
      # needed to add a few -s (parted) and -F (mkfs.ext4) etc. flags to
      # supress prompts
      parted -s /dev/sda -- mklabel gpt
      parted -s /dev/sda -- mkpart primary 512MiB -8GiB
      parted -s /dev/sda -- mkpart primary linux-swap -8GiB 100%
      parted -s /dev/sda -- mkpart ESP fat32 1MiB 512MiB
      parted -s /dev/sda -- set 3 boot on

      mkfs.ext4 -F -L nixos /dev/sda1
      mkswap -L swap /dev/sda2
      swapon /dev/sda2
      echo "y" | mkfs.fat -F 32 -n boot /dev/sda3

      # Labels do not appear immediately, so wait a moment
      sleep 5

      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot

      nixos-generate-config --root /mnt

      # nixos-install will run "nix build --store /mnt ..." which won't be able
      # to see what we have in the installer nix store, so copy everything
      # needed over.
      nix build -f '<nixpkgs/nixos>' system -I "nixos-config=/mnt/etc/nixos/configuration.nix" -o /out
      nix copy --no-check-sigs --to local?root=/mnt /out

      ${installBuild.nixos-install}/bin/nixos-install --no-root-passwd
      reboot
    '';
  };
}
