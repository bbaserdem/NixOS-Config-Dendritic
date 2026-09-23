# Setup the work syncthing folder
{lib, ...}: let
  dirName = "work";
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
            external = lib.mkDefault true;
            text = ''
              // Get document-like files in general
              !*.pdf
              !*.odf
              !*.xls

              // Ignore all temporary code-related files
              .direnv/
              result

              // Env stuff should be synced; we are private
              !.env

              // Single workspace related syncing

              // Superbuilders; get the base level shared config
              !/SuperBuilders/.envrc
              !/SuperBuilders/opencode.json*
              !/SuperBuilders/Passwords.kdbx
              !/SuperBuilders/secretspect.toml
              !/SuperBuilders/SuperBuilders.envrc
              // Whitelist approach; ignore everything else
              /SuperBuilders/*
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
