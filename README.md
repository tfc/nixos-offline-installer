# NixOS offline installer candidate

## How to build

```bash
NIX_PATH="nixpkgs=/..." nix-build
```

## How to test in `qemu`

```bash
qemu-img create -f qcow2 /tmp/qemu-mydisk.img 40G
qemu-system-x86_64 -enable-kvm -boot d -hda /tmp/qemu-mydisk.img -m 2000 -bios $(nix-build '<nixpkgs>' -A pkgs.OVMF.fd --no-out-link)/FV/OVMF.fd -net none -cdrom result/iso/*.iso
```

## Interesting files:

- `install-configuration`:
  - The `configuration.nix` is used by `nixos-generate-config` during installation.
    Customize this to your needs.
  - the `hardware-configuration` will be newly generated on your installation target.
    TODO: add more proprietary modules so the installer can work on more machines.
- `installer-configuration.nix`: This image contains the other image and all the
  interesting scriptery to automate the offline installation.
