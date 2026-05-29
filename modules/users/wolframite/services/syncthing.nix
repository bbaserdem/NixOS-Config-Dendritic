# Provision setup for this user
{...}: {
  localConfig.syncthing.users.wolframite = let
    syncHosts = [
      "su-ana"
      "yel-ana"
    ];
  in {
    # Enable this user to use syncthing
    enable = true;
    # Configure  XDG folders
    xdg = {
      documents = {
        hosts = syncHosts;
        ignore = {
          global = ''
            // Documents: ignores

            // Do not track obsidian workspace files
            .obsidian/workspace.json

            // Zoom deposits files here, do not track
            /Zoom

            // Don't track auxillary latex files
            (?d)*.aux
            (?d)*.bbl
            (?d)*.bcl
            (?d)*.blg
            (?d)*.fdb_latexmk
            (?d)*.fls
            (?d)*.lof
            (?d)*.log
            (?d)*.run.xml
            (?d)*.run.toc
            (?d)*.out
            (?d)*.synctex.gz
            (?d)*.xdv
          '';
          hosts = {
          };
        };
      };
      music = {
        hosts = syncHosts;
        ignore = {
          global = ''
          '';
          hosts = {
            su-ana = ''
              // Su-Ana - Music ignores
              // Assuming this is apple shit
              Music
              Music/*
            '';
          };
        };
      };
      pictures = {
        hosts = syncHosts;
        ignore = {
          global = ''
          '';
          hosts = {
            su-ana = ''
              // Su-Ana - Pictures ignores
              // Assuming this is apple shit
              /Photos Library.photoslibrary
              /Photos Library.photoslibrary/*
            '';
          };
        };
      };
      videos = {
        hosts = syncHosts;
        ignore = {
          global = ''
          '';
          hosts = {
            su-ana = ''
              // Su-Ana - Videos ignores
              // Assuming this is apple shit
              /TV
              /TV/*
            '';
          };
        };
      };
    };
  };
}
