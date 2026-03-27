# Go lang plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.go = {
      lazy = true;
      data = null;
      extraPackages = with pkgs.unstable; [
        go
        gotools
        gopls
      ];
    };
  };
}
