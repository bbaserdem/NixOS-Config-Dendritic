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

              // Calibre; keep things in general but ignore sqlite runtime
              (?d)/Books/metadata.{db-journal,db-wal,db-shm}
              (?d)/Books/.calnotes/notes.{db-journal,db-wal,db-shm}
              (?d)/Books/full-text-search.db
              (?d)/Books/full-text-search.db-*
              (?d)/Books/.caltrash
              !/Books

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
            // Whitelist
            // Passwords
            !/Vaults/Personal.kdbx
                      
            // Ignore EVERYTHING ELSE
            *
          '';
        };
        yertengri = {enable = true;};
        od-ata = {enable = true;};
        yel-ana = {enable = true;};
        # TODO: Figure out how to do this subset
        su-ana = {
          enable = false;
          ignore.text = ''
            // Don't take in non-work related things
            !/Vaults/Work.kdbx
            /Vaults/**
          '';
        };
      }
      |> lib.mapAttrs (_: v: {users.wolframite.mediaDirs.${dirName}.sync = v;});
  };
}
