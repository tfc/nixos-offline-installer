# NixOS offline installer candidate

Interesting files:

- `install-configuration`:
  - The `configuration.nix` is used by `nixos-generate-config` during installation.
    Customize this to your needs.
  - the `hardware-configuration` will be newly generated on your installation target.
    TODO: add more proprietary modules so the installer can work on more machines.
- `installer-configuration.nix`: This image contains the other image and all the
  interesting scriptery to automate the offline installation.
