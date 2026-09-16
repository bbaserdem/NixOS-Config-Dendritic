# Go lang plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.go = {
      lazy = true;
      data = null;
      runtimePackages = with pkgs.unstable; [
        go
        gotools
        gopls
      ];
    };
  };
}
