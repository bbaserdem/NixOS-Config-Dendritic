{inputs, ...}: {
  # Stylix is system-wide theming tool
  # https://github.com/nix-community/stylix

  flake-file.inputs = {
    stylix.url = "github:nix-community/stylix/release-25.11";
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
    # We leave home.stylix as a module to configure apps for stylix
    # The inputs.stylix.homeModules.stylix should be done on standalone context only
  };
}
