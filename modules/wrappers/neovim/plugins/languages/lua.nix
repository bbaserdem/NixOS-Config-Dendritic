# Lua plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.lua = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        lazydev-nvim
        nvim-treesitter-parsers.lua
        nvim-treesitter-parsers.luadoc
        nvim-treesitter-parsers.luap
        nvim-treesitter-parsers.luau
      ];
      extraPackages = with pkgs.unstable; [
        lua-language-server
        stylua
      ];
    };
  };
}
