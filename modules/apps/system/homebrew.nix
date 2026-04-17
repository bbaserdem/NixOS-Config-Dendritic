# Homebrew baseline settings
{...}: {
  flake.modules = {
    darwin.homebrew = {...}: {
      # Enable homebrew
      homebrew = {
        enable = true;
        # Also allow managing app store installations
        brews = [
          "mas"
        ];
        # General behavior
        global = {
          # Always auto-update on commands
          autoUpdate = true;
          # Use nix-darwin's brewfile
          brewfile = true;
        };
        # Behavior during system activation
        onActivation = {
          # Update brew on each system activation
          autoUpdate = true;
          # On activation, uninstall casks that were installed outside nix
          # Leave associated files around, "zap" would remove the files too
          cleanup = "uninstall";
          # Upgrade installed apps
          upgrade = true;
        };
      };
    };
  };
}
