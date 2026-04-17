# Bash config
{...}: {
  flake.modules = {
    # Setup system bash
    nixos.shell = {...}: {
      # Bash options
      programs.bash = {
        # Undistract me stuff
        undistractMe = {
          enable = true;
          timeout = 20;
          playSound = false;
        };
        # Bash settings
        vteIntegration = true;
        interactiveShellInit = ''
          # Fix colors in bash
          case $${TERM} in
            xterm-color|*-256color|xterm-kitty) color_prompt=yes;;
          esac
        '';
      };
    };

    # Setup bash per user
    homeManager.shell = {...}: {
      # Integrations
      home.shell.enableBashIntegration = true;
      services = {
        gpg-agent.enableBashIntegration = true;
      };
      programs = {
        fzf.enableBashIntegration = true;
        direnv.enableBashIntegration = true;
        ghostty.enableBashIntegration = true;
        kitty.shellIntegration.enableBashIntegration = true;
        nix-index.enableBashIntegration = true;
        starship.enableBashIntegration = true;
        yazi.enableBashIntegration = true;
        zoxide.enableBashIntegration = true;

        # Setup zsh
        bash = {
          enable = true;
          enableCompletion = true;
          enableVteIntegration = true;
          historyControl = ["ignoredups"];
        };
      };
    };
  };
}
