# Pored; debloat mac installs
{
  inputs,
  den,
  ...
}: {
  # Upstream source
  flake-file = {
    inputs.pared = {
      url = "github:4evy/pared";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # Aspect
  den.aspects = {
    system = {
      provides.macos = {
        includes = [
          den.aspects.system._.macos._.pared
        ];
        provides.pared = {
          name = "system/macos/pared";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.macos-pared
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.darwin.macos-pared = {pkgs, ...}: {
    key = "macos-pared#darwin";
    imports = [
      inputs.pared.darwinModules.default
    ];
    config = {
      programs.pared = {
        # Install to userspace
        enable = true;
        package = inputs.pared.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # Let each node control it's own
        defaultState = null;
      };
    };
  };
}
