# Configuring jj
{...}: {
  flake.modules.homeManager = {
    # Stylix theming for jjui
    stylix = {...}: {
      stylix.targets.jjui = {
        enable = true;
        colors.enable = true;
        polarity.enable = true;
      };
    };

    # JJ module
    vcs = {pkgs, ...}: {
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
