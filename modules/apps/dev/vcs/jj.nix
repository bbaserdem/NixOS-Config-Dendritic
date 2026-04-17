# Configuring jj
{...}: {
  flake.modules.homeManager = {
    # Stylix theming for jjui
    stylix = {...}: {
      # TODO: Not in release 25.11
      # stylix.targets.jjui = {
      #   enable = true;
      #   colors.enable = true;
      #   polarity.enable = true;
      # };
    };

    # JJ module
    vcs = {pkgs, ...}: {
      programs = {
        # Main jujutsu tool
        jujutsu = {
          enable = true;
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
