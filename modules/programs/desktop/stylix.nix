{inputs, ...}: {
  # Stylix is system-wide theming tool
  # https://github.com/nix-community/stylix

  flake-file.inputs = {
    # Stylix flake-file input is in modules/flake/nixpkgs.nix for easy update
    base16.url = "github:SenchoPens/base16.nix";
    tinted-terminal = {
      url = "github:tinted-theming/tinted-terminal";
      flake = false;
    };
  };

  # Flake modules that enables stylix
  flake.modules = {
    nixos.stylix = {...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
      ];
    };

    darwin.stylix = {...}: {
      imports = [
        inputs.stylix.darwinModules.stylix
      ];
    };

    # We don't import the home-manager module, since we use home-manager as system module
    # In standalone, the home-manager module will need to be loaded
    homeManager.stylix = {...}: {
      # imports = [
      #   inputs.stylix.homeModules.stylix
      # ];
    };

    # Generic settings for both contexts
    # Stylix should have a theme set
    generic.stylix = {...}: {
      stylix = {
      };
    };
  };
}
