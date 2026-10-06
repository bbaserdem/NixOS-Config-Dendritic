# Setup the videos syncthing folder
{lib, ...}: let
  dirName = "videos";
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
              /TV
              /TV/*
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
            //
          '';
        };
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {enable = true;};
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
