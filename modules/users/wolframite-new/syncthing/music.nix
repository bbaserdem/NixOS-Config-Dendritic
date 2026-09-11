# Setup the music syncthing folder
{lib, ...}: let
  dirName = "music";
in {
  den = let
    mobileStignore = ''
      // Get the mobile directory only
      /Mobile/.mpdignore
      !/Mobile/*.m3u
      !/Mobile/*
      !/Mobile/**

      // Ignore everything else
      /*
    '';
  in {
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
              // Ignore mpdignore files; we do this with home-manager
              .mpdignore

              // Apple bullshit
              /Music
              /Music/*
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
          ignore.text = mobileStignore;
        };
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {
        #   enable = true;
        #   ignore.text = mobileStignore;
        # };
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
