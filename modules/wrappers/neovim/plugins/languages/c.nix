# C languages plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.c = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.c
        nvim-treesitter-parsers.c3
        nvim-treesitter-parsers.c_sharp
        nvim-treesitter-parsers.cpp
        nvim-treesitter-parsers.cmake
        nvim-treesitter-parsers.cuda
      ];
      extraPackages = with pkgs.unstable; [
        clang-tools
      ];
    };
  };
}
