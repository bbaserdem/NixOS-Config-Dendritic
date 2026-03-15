# Package definitions
{inputs, ...}: {
  # The neovim nightly flake
  flake-file.inputs = {
    # Nightly build
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  # Custom neovim packages
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = let
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
      neovim-stable = pkgs.neovim-unwrapped;
    in {
      # The full neovim package
      neovim-full = config.packages.neovim.wrap {
        # Use nightly neovim
        package = neovim-nightly;
        # Replace system nvim command
        settings = {
          dont_link = true;
          aliases = [
            "nx"
            "nx-full"
          ];
        };
        binName = "nvim";
      };

      # The bare neovim package
      neovim-bare = config.packages.neovim.wrap {
        # Use neovim from nixpkgs
        package = neovim-stable;
        # Replace system nvim command
        settings = {
          dont_link = true;
          aliases = [
            "nx-none"
          ];
        };
        binName = "vim";
        # Disable all specs; tbd
      };

      # The classic neovim package
      neovim-native = config.packages.neovim.wrap {
        # Use neovim nightly
        package = neovim-nightly;
        # Replace system nvim command
        settings = {
          dont_link = true;
        };
        binName = "neovim";
        # Disable all specs; tbd
        # Default to system config, disable our config; tbd
      };
    };
  };
}
