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
    # Generic behavior settings for all contexts
    generic.stylix = {...}: {
      stylix = {
        autoEnable = false;
      };
    };

    # Context-specific module loading
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

    # Stylix tries to apply package overlays in home-manager, disable this
    homeManager.stylix = {...}: {
      imports = [
        inputs.stylix.homeModules.stylix
      ];

      # Stylix settings
      stylix = {
        overlays.enable = false;
      };
    };
  };
}
