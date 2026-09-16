# Configuring neovide that depends on neovim
{inputs, ...}: {
  flake.modules = {
    homeManager = {
      # Stylix theme for neovide
      stylix = {lib, ...}: {
        stylix.targets.neovide = {
          enable = true;
          fonts.enable = lib.mkDefault true;
          opacity.enable = true;
        };
      };

      # Home manager module to install full neovim module
      neovide = {...}: {
        imports = [
          inputs.self.modules.homeManager.neovim-neovide
        ];
      };
    };
  };
}
