# Lua plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.lua = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        lazydev-nvim
      ];
      extraPackages = with pkgs; [
        lua-language-server
        stylua
      ];
    };
  };
}
