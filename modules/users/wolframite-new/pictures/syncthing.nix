# Setup the pictures syncthing folder
{lib, ...}: let
  dirName = "pictures";
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
              // Apple bullshit
              /Photos Library.photoslibrary
              /Photos Library.photoslibrary/**
            '';
          };
        };
      };
    };

    # Host specific config
    hosts =
      {
        erlik = {
          enable = true;
          ignore.text = ''
            // Ignore main photos and staging
            /Personal
            /Personal/**
            /Photos
            /Photos/**

            // Don't need the projects
            /Projects
            /Projects/**
          '';
        };
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {enable = true;};
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
