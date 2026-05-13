# Configuring neovide that depends on neovim
{...}: {
  flake.modules = {
    homeManager = {
      # Stylix theme for neovide
      stylix = {...}: {
        stylix.targets.neovide = {
          enable = true;
          fonts.enable = true;
          opacity.enable = false;
        };
      };

      # Home manager module to install full neovim module
      neovide = {
        lib,
        config,
        pkgs,
        options,
        ...
      }: {
        config = lib.mkMerge [
          {
            # Also install neovide in our system, configured to use our neovim
            programs.neovide = {
              enable = true;
              # Pull from unstable
              package = pkgs.unstable.neovide;
            };
          }
          ( # Link the neovim wrapper editor if enabled
            lib.optionalAttrs (lib.hasAttrByPath ["wrappers" "neovim"] options) (
              let
                neovim-bin = lib.getExe config.wrappers.neovim.wrapper;
              in {
                programs.neovide.settings.neovim-bin = neovim-bin;
              }
            )
          )
        ];
      };
    };
  };
}
