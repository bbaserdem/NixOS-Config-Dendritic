# Setup the android syncthing folder
{lib, ...}: let
  dirName = "documents";
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
              // Do not track obsidian workspace files
              .obsidian/workspace.json
              .obsidian/workspace-mobile.json

              // Zoom deposits files here, do not track
              /Zoom

              // Do not track auxillary latex files
              (?d)*.aux
              (?d)*.bbl
              (?d)*.bcl
              (?d)*.bcf
              (?d)*.blg
              (?d)*.fdb_latexmk
              (?d)*.fls
              (?d)*.lof
              (?d)*.log
              (?d)*.run.xml
              (?d)*.run.toc
              (?d)*.toc
              (?d)*.out
              (?d)*.synctex.gz
              (?d)*.xdv
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
            // Ignore everything for now
            *
          '';
        };
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {enable = true;};
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
