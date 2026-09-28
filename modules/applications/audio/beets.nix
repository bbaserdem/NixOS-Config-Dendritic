# Enabling audio tagging toolkit; (also provides picard)
{
  inputs,
  flib,
  ...
}: {
  den = {
    aspects.audio = {
      provides.beets = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "audio/tagging(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              beets-settings
              picard-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager = {
    # Beets, enables but do the actual config in userspace
    beets-settings = {
      config,
      lib,
      ...
    }: let
      inHome = path: lib.hasPrefix "${config.home.homeDirectory}/" path;
      relativeParent = path:
        flib.stripRootDir config.home.homeDirectory (builtins.dirOf path);
      set = config.programs.beets.settings;
    in {
      key = "beets-settings#homeManager";
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
          lib.mkIf (inHome (set.import.log or "")) {
            home.file."${relativeParent set.import.log}/.keep".text = "";
          }
        )
        (
          lib.mkIf (inHome (set.library or "")) {
            home.file."${relativeParent set.library}/.keep".text = "";
          }
        )
      ];
    };
    picard-settings = {pkgs, ...}: {
      key = "music-picard#homeManager";
      config = {
        # TODO: Add importing picard config here
        home.packages = with pkgs; [
          picard
        ];
      };
    };
  };
}
