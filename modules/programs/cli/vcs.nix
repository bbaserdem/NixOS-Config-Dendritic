# Configuring vcs for users
# Provide settings for;
# - git
# - jj
{...}: {
  flake.modules.home-manager.vcs = {config, ...}: {
    programs = {
      # Configuring vcs tooling here

      # Main git tool
      git = {
        enable = true;
        lfs.enable = true;
        settings = {
          alias = {
            pu = "push";
            co = "checkout";
            cm = "commit";
          };
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

      # Main jujutsu tool
      jujutsu = {
        enable = true;
      };

      # Diff pager
      delta = {
        enable = true;
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
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

      # TUI for jujutsu
      jjui = {
        enable = true;
      };
    };
  };
}
