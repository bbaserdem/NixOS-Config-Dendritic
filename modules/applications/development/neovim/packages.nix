# Custom package definitions
{...}: {
  # Output to packages
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: {
    packages = {
      # Full output already available with nix run .#neovim

      # Minimal neovim, for testing the minimal config with nix run .#neovim-bare
      neovim-bare = config.packages.neovim.wrap {
        # Use neovim from regular nixpkgs
        package = lib.mkOverride 1400 pkgs.neovim-unwrapped;
        # Replace
        binName = "nvim-bare";
        settings = {
          dont_link = true;
          # Disable specs
          minimal = true;
          # Use default colorscheme
          colorscheme = {
            dark = "default";
            light = "default";
          };
        };
      };
    };
  };
}
