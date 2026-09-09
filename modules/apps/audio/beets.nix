# Enabling beets
{inputs, ...}: {
  flake.modules = {
    homeManager.beets = {
      config,
      lib,
      ...
    }: let
      inHome = path: lib.hasPrefix "${config.home.homeDirectory}/" path;
      relativeParent = path:
        inputs.self.lib.stripRootDir config.home.homeDirectory (builtins.dirOf path);
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
          lib.mkIf (inHome config.programs.beets.settings.import.log) {
            home.file."${relativeParent config.programs.beets.settings.import.log}/.keep".text = "";
          }
        )
        (
          lib.mkIf (inHome config.programs.beets.settings.library) {
            home.file."${relativeParent config.programs.beets.settings.library}/.keep".text = "";
          }
        )
      ];
    };
  };
}
