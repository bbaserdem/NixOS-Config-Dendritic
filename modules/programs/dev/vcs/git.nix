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
