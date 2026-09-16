# Lua plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.lua = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        lazydev-nvim
      ];
      runtimePackages = with pkgs.unstable; [
        lua-language-server
        stylua
      ];
    };
  };
}
