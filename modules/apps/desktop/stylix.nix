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
        enable = true;
        autoEnable = false;
      };
    };

    # Context-specific module loading
    nixos.stylix = {...}: {
      imports = [
        inputs.stylix.nixosModules.stylix
        inputs.self.modules.generic.stylix
      ];
    };
    darwin.stylix = {...}: {
      imports = [
        inputs.stylix.darwinModules.stylix
      ];
    };

    # In standalone hm context, this module needs to be loaded
    homeManager.stylix-hms = {...}: {
      imports = [
        inputs.stylix.homeModules.stylix
      ];
    };
  };
}
