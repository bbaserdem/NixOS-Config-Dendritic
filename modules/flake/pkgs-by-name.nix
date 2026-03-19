{
  inputs,
  withSystem,
  ...
}: {
  flake-file.inputs = {
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    packages = {
      url = "path:./packages";
      flake = false;
    };
  };

  imports = [
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  perSystem = {...}: {
    pkgsDirectory = inputs.packages;
  };

  flake = {
    overlays.additions = _final: prev: {
      # Overlay with a namespace to pull in our exported packages
      local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    };
  };
}
