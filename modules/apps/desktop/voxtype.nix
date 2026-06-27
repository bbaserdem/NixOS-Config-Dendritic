# Voxtype; STT solution
{inputs, ...}: {
  # We pull the upstream flake for the home-manager module mostly
  # TODO: Module in home-manager unstable; switch to that once done
  flake-file.inputs = {
    voxtype = {
      url = "github:peteonrails/voxtype";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  flake.modules = {
    nixos.voxtype = {
      pkgs,
      lib,
      ...
    }: {
      # Configure voxtype per system
      imports = [
        inputs.voxtype.nixosModules.default
      ];

      config = {
        programs.voxtype = {
          enable = true;
          # Fetch from nixpkgs
          package = lib.mkOverride 1400 pkgs.voxtype;
        };
      };
    };

    darwin.voxtype = {...}: {
      # Install from custom homebrew tap
      homebrew = {
        taps = ["peteonrails/voxtype"];
        brews = ["voxtype"];
      };
    };

    homeManager.voxtype = {
      pkgs,
      lib,
      ...
    } @ args: {
      # Configure voxtype
      imports = [
        inputs.voxtype.homeManagerModules.default
      ];

      config = lib.mkMerge [
        (
          # Module is linux only for now
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (
            lib.mkMerge [
              (
                # Pull from nixos config if we are nixos module
                lib.optionalAttrs (lib.hasAttrByPath ["osConfig"] args) {
                  programs.voxtype.package = args.osConfig.programs.voxtype.package;
                }
              )
              (
                # Default to regular if we are not
                lib.optionalAttrs (!(lib.hasAttrByPath ["osConfig"] args)) {
                  programs.voxtype.package = pkgs.voxtype;
                }
              )
              {
                # Config
                programs.voxtype = {
                  enable = true;
                  # Enable the systemd service
                  service.enable = true;
                  # Global settings;
                  settings = {};
                };
              }
            ]
          )
        )
      ];
    };
  };
}
