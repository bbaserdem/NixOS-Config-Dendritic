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
                // Ignore these directories very explicitly
                /Android
                /Android/**
                /Music
                /Music/**
                /Documents
                /Documents/**
                              
                // Whitelist some of use directories

                // Basic android folders
                !/Alarms
                !/Alarms/**
                !/Audiobooks
                !/Audiobooks/**
                !/Backups
                !/Backups/**
                !/Recordings
                !/Recordings/**
                !/Ringtones
                !/Ringtones/**

                // We keep phone downloads seperate from our system downloads
                !/Download
                !/Download/**

                // Same with videos; video library != videos from phone
                !/Movies
                !/Movies/**
                !/Videos
                !/Videos/**

                // Same with pictures; TODO: this will integrate later
                !/Pictures
                !/Pictures/**
                !/DCIM
                !/DCIM/**

                // Ignore EVERYTHING ELSE, and ignore 
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
        od-ata = {enable = true;};
        yel-ana = {enable = true;};
        su-ana = {enable = false;};
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
