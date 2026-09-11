# Setup the android syncthing folder
{lib, ...}: let
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
        mediaDirs.${dirName}.sync = {
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

    # Host specific config
    hosts =
      {
        erlik = {enable = true;};
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {enable = false;};
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
