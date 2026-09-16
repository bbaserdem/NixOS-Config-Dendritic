# Git VCS setup
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.git = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/git(${user.userName}@${host.name})";
          # Import to user profile
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.vcs-git
            ];
          };
          # Enable stylix theming
          stylix = {
            targets.lazygit = {
              enable = true;
              colors.enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.vcs-git = {
    pkgs,
    config,
    lib,
    ...
  }: {
    key = "vcs-git#homeManager";
    config = lib.mkMerge [
      {
        # Main git config
        programs.git = {
          enable = true;
          lfs.enable = true;
          settings = {
            core = {editor = config.home.sessionVariables.EDITOR;};
            pull = {rebase = false;};
            push = {autoSetupRemote = true;};
            init = {defaultBranch = "main";};
            diff = {algorithm = "histogram";};
            merge = {
              conflictstyle = "zdiff3";
              log = true;
            };
            rebase = {
              autoStash = true;
              updateRefs = true;
            };
            fetch = {prune = false;};
            rerere = {enabled = true;};
            column = {ui = "auto";};
          };
        };

        # TUI for git
        programs.lazygit = {
          enable = true;
          settings = {
            git = {
              commit.autoWrapWidth = 80;
              parseEmoji = true;
              mainBranches = [
                "main"
                "master"
              ];
            };
            os = {edit = "${config.home.sessionVariables.EDITOR} {{filename}}";};
          };
        };

        # Install hook packages
        home.packages = with pkgs; [
          pre-commit
          pre-commit-hook-ensure-sops
          gitleaks
        ];
      }
      (
        # Linux-only tooling
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          home.packages = with pkgs; [
            # Git tree visualizer
            gitg
          ];
        }
      )
    ];
  };
}
