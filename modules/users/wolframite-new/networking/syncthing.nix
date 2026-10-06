# Setup the downloads syncthing folder
{lib, ...}: let
  dirName = "download";
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
            '';
          };
        };
      };
    };

    # Host specific config
    hosts =
      {
        erlik = {enable = false;};
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {enable = true;};
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
