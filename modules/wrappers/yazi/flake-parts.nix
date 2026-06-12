# Flake-Parts module for yazi config wrapper; dispatches to the home module
{config, ...}: let
  yaziInstall = config.flake.wrappers.yazi.install;
in {
  flake.modules = {
    homeManager.yazi = {
      config,
      lib,
      options,
      ...
    }: {
      imports = [
        yaziInstall
      ];

      config = lib.mkMerge [
        {
          # Override the package with us
          programs.yazi.package = config.wrappers.yazi.wrapper;
        }
        (
          lib.optionalAttrs (lib.hasAttrByPath ["stylix"] options) {
            # Pull the stylix theme if available
            wrappers.yazi.settings.theme = config.programs.yazi.theme;
          }
        )
      ];
    };
  };
}
