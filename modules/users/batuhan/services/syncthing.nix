# Provision setup for this user
{...}: {
  localConfig.syncthing.users.batuhan = let
    syncHosts = [
      "su-ana"
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
            su-ana = ''
              // Testing host su-ana dispatch
            '';
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
            '';
          };
        };
      };
    };
  };
}
