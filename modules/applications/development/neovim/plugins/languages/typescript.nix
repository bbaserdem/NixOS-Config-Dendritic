# Typescript editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.typescript = {
      lazy = true;
      data = null;
      runtimePackages = with pkgs.unstable; [
        typescript-language-server
      ];
    };
  };
}
