# Go lang plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.go = {
      lazy = true;
      data = null;
      extraPackages = with pkgs; [
        go
        gotools
      ];
    };
  };
}
