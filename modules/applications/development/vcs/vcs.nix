# Common VCS tooling
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.vcs = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/vcs(${user.userName}@${host.name})";
          # Install apps through brew in darwin
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.vcs-applications
            ];
          };
          # Install apps through homeManager
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.vcs-applications
            ];
          };
        };
      };
    };
  };

  flake.modules.darwin.vcs-applications = {...}: {
    key = "vcs-applications#darwin";
    config = {
      # Install github app from homebrew
      homebrew.casks = ["github"];
    };
  };
  flake.modules.homeManager.vcs-applications = {
    pkgs,
    config,
    lib,
    ...
  }: {
    key = "vcs-applications#homeManager";
    config = lib.mkMerge [
      {
        # Enable delta for diff formatting
        programs.delta = {
          enable = true;
          enableGitIntegration = true;
          enableJujutsuIntegration = true;
        };
        # Github cli tooling
        programs.gh = {
          enable = true;
          gitCredentialHelper.enable = true;
          settings = {
            editor = config.home.sessionVariables.EDITOR or "nvim";
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
        programs.gh-dash = {
          enable = true;
        };

        # Install other clients
        home.packages = with pkgs; [
          # GitLab client
          glab
          # Forgejo/Gitea CLI
          tea
        ];
      }
      (
        # Linux only tooling
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          home.packages = with pkgs; [
            # Github tooling
            github-desktop
          ];
        }
      )
    ];
  };
}
