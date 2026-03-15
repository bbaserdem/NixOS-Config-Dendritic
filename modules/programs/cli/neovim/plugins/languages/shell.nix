# Shell editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.shell = {
      lazy = true;
      data = null;
      extraPackages = with pkgs; [
        bash
        dash
        dotenv-linter
        shellcheck
      ];
    };
  };
}
