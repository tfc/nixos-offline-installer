{
  nixpkgs ? <nixpkgs>,
  pkgs ? import nixpkgs {}
}:
let
  createConfig = x: import <nixpkgs/nixos> { configuration = x; };
  installConfigurationPath = ./install-configuration/configuration.nix;
  installConfiguration =
    (createConfig (import ./install-configuration/configuration.nix)).config;
  configuration = import ./installer-configuration.nix {
    inherit installConfiguration installConfigurationPath;
  };
  nixos = createConfig configuration;
in nixos.config.system.build.isoImage
