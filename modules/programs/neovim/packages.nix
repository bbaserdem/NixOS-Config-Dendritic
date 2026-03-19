# Custom package definitions
# Mainly so that we can test the minimal config with nix run .#neovim-bare
{...}: {
  # Custom neovim package with the minimal config
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: {
    packages = {
      # The bare neovim package
      neovim-bare = config.packages.neovim.wrap {
        # Use neovim from regular nixpkgs
        package = lib.mkOverride 1400 pkgs.neovim-unwrapped;
        # Replace system nvim command
        settings = {
          dont_link = true;
          aliases = [
            "nvim-none"
          ];
          # Disable specs
          minimal = true;
        };
        binName = "vim";
      };
    };
  };
}
