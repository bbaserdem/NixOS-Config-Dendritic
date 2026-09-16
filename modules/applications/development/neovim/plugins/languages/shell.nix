# Shell editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.shell = {
      lazy = true;
      data = null;
      runtimePackages = with pkgs.unstable; [
        bash
        dash
        dotenv-linter
        shellcheck
      ];
    };
  };
}
