# Nix plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.nix = {
      lazy = true;
      data = null;
      extraPackages = with pkgs.unstable; [
        manix
        nix-doc
        nixd
        alejandra
      ];
    };
  };
}
