# Setup the android share folder
{
  lib,
  den,
  ...
}: let
  dirName = "android";
in {
  den = {
    # Establish defaults for wolframite user
    schema.user = {
      config,
      lib,
      ...
    }: {
      config = lib.mkIf (config.name == "wolframite") {
        mediaDirs.${dirName} = {
          location = "Shared/Android";
          externalize = true;
          # Syncthing settings
          sync = {
            enable = lib.mkDefault true;
            ignore = {
              external = lib.mkDefault false;
              text = ''
                // Only allow several directories, disable everything else
                !/Alarms
                !/Alarms/**
                !/Audiobooks
                !/Audiobooks/**
                !/Backups
                !/Backups/**
                !/DCIM
                !/DCIM/**
                !/Recordings
                !/Recordings/**
                !/Ringtones
                !/Ringtones/**
                *
              '';
            };
          };
        };
      };
    };

    # Host specific syncthing settings directly in aspect
    hosts =
      {
        erlik = {enable = true;};
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {enable = false;};
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});

    # Module for android folder settings
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.android
      ];
      provides.android = {
        user,
        host,
      }: {
        name = "wolframite/android(${user.userName}@${host.name})";
        homeManager = {config, ...}: {
          config = {
            # Set android location to xdg directories
            xdg.userDirs.extraConfig.PHONE =
              lib.mkIf
              (user.mediaDirs ? android)
              "${config.home.homeDirectory}/${user.mediaDirs.android.location}";
          };
        };
      };
    };
  };
}
