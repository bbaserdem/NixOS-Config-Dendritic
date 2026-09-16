# C languages plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.c = {
      lazy = true;
      data = null;
      runtimePackages = with pkgs.unstable; [
        clang-tools
      ];
    };
  };
}
