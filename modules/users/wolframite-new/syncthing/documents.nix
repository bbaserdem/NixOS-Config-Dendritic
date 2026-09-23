# Setup the android syncthing folder
# TODO: Transition generic password storage work-based to work directory
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

              // Lots of apps deposit random files in Documents folder
              // We want to follow a whitelist approach for folders
              // For easy access documents; will be superceded by Paperless
              !/Administration
              // Calibre
              !/Books
              // Obsidian
              !/Notes
              // Zotero
              !/Papers
              // Staging directories
              !/Sort
              !/Staging
              // Passwords
              !/Vaults
              // Ignore all top level directories not mentioned
              /*/
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
            // Ignore everything not accounted for; for the time being
            *
          '';
        };
        yertengri = {enable = true;};
        # yel-ana = {enable = true;};
        # su-ana = {
        #   enable = true;
        #   ignore.text = ''
        #     // Ignore all non-work related passwords
        #     !/Vaults/Work.kdbx
        #     /Vaults/**
        #   '';
        # };
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
