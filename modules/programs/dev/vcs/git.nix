# Configuring git
{...}: {
  flake.modules.homeManager = {
    # Theme lazygit with stylix
    stylix = {...}: {
      stylix.targets.lazygit = {
        enable = true;
        colors.enable = true;
      };
    };

    # Git module
    git = {
      config,
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        {
          programs = {
            # Main git config
            git = {
              enable = true;
              lfs.enable = true;
              settings = {
                core = {
                  editor = config.home.sessionVariables.EDITOR;
                };
                pull = {
                  rebase = false;
                };
                push = {
                  autoSetupRemote = true;
                };
                init = {
                  defaultBranch = "main";
                };
                diff = {
                  algorithm = "histogram";
                };
                merge = {
                  conflictstyle = "zdiff3";
                  log = true;
                };
                rebase = {
                  autoStash = true;
                  updateRefs = true;
                };
                fetch = {
                  prune = false;
                };
                rerere = {
                  enabled = true;
                };
                column = {
                  ui = "auto";
                };
              };
            };

            # TUI for git
            lazygit = {
              enable = true;
              settings = {
                git = {
                  commit.autoWrapWidth = 80;
                  mainBranches = [
                    "main"
                    "master"
                  ];
                  parseEmoji = true;
                };
                os = {
                  edit = "${config.home.sessionVariables.EDITOR} {{filename}}";
                };
              };
            };

            # Github: most commonly used git provider
            gh = {
              enable = true;
              gitCredentialHelper.enable = true;
              settings = {
                editor = config.home.sessionVariables.EDITOR;
                git_protocol = "ssh";
              };
              extensions = with pkgs; [
                gh-s
                gh-i
                gh-f
                gh-poi
                gh-eco
                gh-notify
                gh-skyline
                gh-contribs
                gh-screensaver
                gh-markdown-preview
              ];
            };
            gh-dash = {
              enable = true;
            };
          };
        }
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            gitg
          ];
        })
      ];
    };
  };
}
