{
  inputs,
  withSystem,
  ...
}: {
  imports = [
    (inputs.pkgs-by-name.flakeModule or {})
  ];

  config = {
    flake-file.inputs = {
      pkgs-by-name.url = "github:drupol/pkgs-by-name-for-flake-parts";
      packages = {
        url = "path:./packages";
        flake = false;
      };
    };

    perSystem = {...}: {
      pkgsDirectory = inputs.packages;
    };

    nixpkgs.overlays = [
      inputs.self.overlays.additions
    ];

    flake.overlays.additions = _final: prev: {
      # Overlay with a namespace to pull in our exported packages
      local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    };
  };
}
