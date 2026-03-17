# Rust development plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.rust = {
      lazy = true;
      data = null;
      extraPackages = with pkgs; [
        rustfmt
        rust-analyzer
      ];
    };
  };
}
