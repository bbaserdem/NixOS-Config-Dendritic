# Rust development plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.rust = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.rust
      ];
      extraPackages = with pkgs.unstable; [
        rustfmt
        rust-analyzer
      ];
    };
  };
}
