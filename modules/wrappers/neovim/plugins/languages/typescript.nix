# Typescript editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.typescript = {
      lazy = true;
      data = null;
      extraPackages = with pkgs.unstable; [
        typescript-language-server
      ];
    };
  };
}
