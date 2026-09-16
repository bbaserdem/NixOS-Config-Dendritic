# JJ VCS setup
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.jujutsu = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/jujutsu(${user.userName}@${host.name})";
          # Import to user profile
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.vcs-jujutsu
            ];
          };
          # Enable stylix theming
          stylix = {
            targets.jjui = {
              enable = true;
              colors.enable = true;
              polarity.enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.vcs-jujutsu = {pkgs, ...}: {
    key = "vcs-jujutsu#homeManager";
    config = {
      programs = {
        # Main jujutsu tool
        jujutsu = {
          enable = true;
          settings = {
            snapshot = {
              max-new-file-size = "25MiB";
            };
          };
        };

        # TUI for jujutsu
        jjui = {
          enable = true;
        };
      };

      # Also add userspace packages
      home.packages = with pkgs; [
        lazyjj # Lazygit like util for jj
      ];
    };
  };
}
