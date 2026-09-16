# Path directory settings
{...}: {
  flake.modules = {
    # Nixos module to add local bin to path
    # Easy peasy
    nixos.shell-path = {...}: {
      key = "shell-path#nixos";
      config = {
        environment.localBinInPath = true;
      };
    };

    # Darwin module to add local bin to path
    darwin.shell-path = {...}: {
      key = "shell-path#darwin";
      config = {
        # Add homebrew sourcing to path
        homebrew = {
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };
        # Add local bin to path
        environment.systemPath = ["$HOME/.local/bin"];
      };
    };
  };
}
