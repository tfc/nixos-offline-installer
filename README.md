# NixOS offline installer demo (untested since 21.05)

## How to build

To build the installer with the `<nixpkgs>` in your `NIX_PATH`, just do:

```bash
nix-build installer-iso.nix
```

To build the installer with the `<nixpkgs>` from the `niv` sources in `nix/sources.json`, do:

```bash
nix-build
```

## How to test in `qemu`

```bash
qemu-img create -f qcow2 /tmp/qemu-mydisk.img 40G
qemu-system-x86_64 -enable-kvm -boot d -hda /tmp/qemu-mydisk.img -m 2000 -bios $(nix-build '<nixpkgs>' -A pkgs.OVMF.fd --no-out-link)/FV/OVMF.fd -net none -cdrom result/iso/*.iso
```

## Interesting files:

- `installer-iso.nix`: This file assembles the NixOS configs and emits an
  installer ISO derivation.
- `installer-configuration.nix`: This image contains the other image and all the
  interesting scriptery to automate the offline installation.
- `install-configuration.nix`: This configuration is used by
  `nixos-generate-config` during installation. Customize this to your needs.
  - This must stay one file. During installation, the
    `hardware-configuration.nix` is still automatically generated. After
    installation, you may add the generated `hardware-configuration.nix` to your
    `imports = [ ... ];` configuration field. Having it in during installation
    risks the functioning of the installer, because it is hard to predict what
    dependencies it will contain.
