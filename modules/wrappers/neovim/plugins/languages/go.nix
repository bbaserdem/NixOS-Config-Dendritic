# Go lang plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.go = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.go
      ];
      extraPackages = with pkgs.unstable; [
        go
        gotools
        gopls
      ];
    };
  };
}
