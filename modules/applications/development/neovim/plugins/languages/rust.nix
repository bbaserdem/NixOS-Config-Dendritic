# Rust development plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.rust = {
      lazy = true;
      data = null;
      runtimePackages = with pkgs.unstable; [
        rustfmt
        rust-analyzer
      ];
    };
  };
}
