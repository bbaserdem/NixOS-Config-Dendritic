# C languages plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.c = {
      lazy = true;
      data = null;
      extraPackages = with pkgs.unstable; [
        clang-tools
      ];
    };
  };
}
