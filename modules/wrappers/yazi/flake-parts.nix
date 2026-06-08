# Flake-Parts module for yazi config wrapper
{config, ...}: let
  yaziInstall = config.flake.wrappers.yazi.install;
in {
  flake.modules = {
    homeManager.yazi = {config, ...}: {
      imports = [
        yaziInstall
      ];

      programs.yazi = {
        enable = true;
        package = config.wrappers.yazi.wrapper;
      };
    };
  };
}
