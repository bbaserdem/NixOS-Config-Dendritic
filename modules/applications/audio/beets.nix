# Enabling beets
{flib, ...}: {
  flake.modules.homeManager.beets-settings = {
    config,
    lib,
    ...
  }: let
    inHome = path: lib.hasPrefix "${config.home.homeDirectory}/" path;
    relativeParent = path:
      flib.stripRootDir config.home.homeDirectory (builtins.dirOf path);
  in {
    config = lib.mkMerge [
      {
        # Enable beets in userspace
        # The rest of the config should be user-specific
        programs.beets = {
          enable = true;
        };
      }
      # Create log/cache paths if we can
      (
        lib.mkIf (inHome (config.programs.beets.settings.import.log or "")) {
          home.file."${relativeParent config.programs.beets.settings.import.log}/.keep".text = "";
        }
      )
      (
        lib.mkIf (inHome (config.programs.beets.settings.library or "")) {
          home.file."${relativeParent config.programs.beets.settings.library}/.keep".text = "";
        }
      )
    ];
  };
}
