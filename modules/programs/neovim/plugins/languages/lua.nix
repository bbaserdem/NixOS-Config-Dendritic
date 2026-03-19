# Lua plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.lua = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        lazydev-nvim
      ];
      extraPackages = with pkgs.unstable; [
        lua-language-server
        stylua
      ];
    };
  };
}
