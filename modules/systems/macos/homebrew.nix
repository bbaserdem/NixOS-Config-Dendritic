# Homebrew baseline settings
{
  inputs,
  den,
  ...
}: {
  den.aspects = {
    # Base configuration for all NixOS systems
    system = {
      provides.macos = {
        includes = [
          den.aspects.system._.macos._.homebrew
        ];
        provides.homebrew = {
          name = "system/macos/homebrew";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.macos-homebrew
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.darwin.macos-homebrew = {...}: {
    key = "macos-homebrew#darwin";
    config = {
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
          # TODO: brew refuses to do cleanup w/out either force, force-cleanup or HOMEBREW_ASK
          # cleanup = "uninstall";
          # Upgrade installed apps
          upgrade = true;
        };
      };
    };
  };
}
