# Nix plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.nix = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.nix
      ];
      extraPackages = with pkgs.unstable; [
        manix
        nix-doc
        nixd
        alejandra
      ];
    };
  };
}
