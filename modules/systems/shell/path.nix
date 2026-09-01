# Path directory settings
{...}: {
  flake.modules = {
    # Nixos module to add local bin to path
    # Easy peasy
    nixos.shell-path = {...}: {
      environment.localBinInPath = true;
    };

    # Darwin module to add local bin to path
    darwin.shell-path = {...}: {
      # Add homebrew sourcing to path
      homebrew = {
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };
    };
  };
}
