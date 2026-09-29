# Git VCS setup
{inputs, ...}: {
  den = {
    # Dispatch done by vcs.nix
    aspects.development = {
      provides.vcs = {
        provides.git = {
          name = "development/vcs/git";
          provides.to-users = {
            host,
            user,
          }: {
            name = "development/vcs/git(${user.userName}@${host.name})";
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
  };

  # Module
  flake.modules.homeManager.vcs-git = {
    pkgs,
    config,
    lib,
    ...
  }: {
    key = "vcs-git#homeManager";
    config = {
      programs = {
        # Main git config
        git = {
          enable = true;
          lfs.enable = true;
          settings = {
            core = {editor = config.home.sessionVariables.EDITOR or "nvim";};
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
        lazygit = {
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
            os = {
              edit = "${config.home.sessionVariables.EDITOR or "nvim"} {{filename}}";
            };
          };
        };

        # Worktree switcher.
        git-worktree-switcher.enable = true;
        # TODO: Move integrations to shell module
        git-worktree-switcher = {
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };
      };

      # Install hook packages
      home.packages = with pkgs; ([
          pre-commit
          pre-commit-hook-ensure-sops
          gitleaks
        ]
        ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # Linux-only
          gitg
        ]));
    };
  };
}
