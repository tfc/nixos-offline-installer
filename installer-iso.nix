let
  nixos = import <nixpkgs/nixos> {
    configuration = import ./installer-configuration.nix {
      installConfigurationPath = ./install-configuration.nix;
    };
  };
in nixos.config.system.build.isoImage
