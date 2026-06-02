# Go lang plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.go = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.go
      ];
      runtimePackages = with pkgs.unstable; [
        go
        gotools
        gopls
      ];
    };
  };
}
