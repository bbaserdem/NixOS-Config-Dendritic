# Path directory settings
{...}: {
  flake.modules = {
    # Nixos module to add local bin to path
    # Easy peasy
    nixos.shell = {...}: {
      environment.localBinInPath = true;
    };

    # Darwin module to add local bin to path
    darwin.shell = {...}: {
      # Add homebrew sourcing to path
      homebrew = {
        # TODO: not in stable yet
        # enableBashIntegration = true;
        # enableFishIntegration = true;
        # enableZshIntegration = true;
      };
      # Local is a little more complicated, no default implementation on darwin
      # We just propagate it to shared home-manager modules
      home-manager.sharedModules = [
        (
          # Add local/bin to user session variables
          {config, ...}: {
            home.sessionPath = [
              "${config.home.homeDirectory}/.local/bin"
            ];
          }
        )
      ];
    };
  };
}
