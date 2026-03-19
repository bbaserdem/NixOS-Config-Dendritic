# Configuring git
{...}: {
  flake.modules.home-manager.git = {
    config,
    pkgs,
    ...
  }: {
    programs = {
      # Main git config
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

      # Also add userspace packages
      home.packages = with pkgs; (
        [
        ]
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux
          then [
            gitg
          ]
          else if pkgs.stdenv.hostPlatform.isDarwin
          then []
          else []
        )
      );
    };
  };
}
