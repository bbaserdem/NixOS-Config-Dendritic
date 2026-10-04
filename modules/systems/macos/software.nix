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
          den.aspects.system._.macos._.software
        ];
        provides.software = {host}: {
          name = "system/macos/software(@${host.name})";
          darwin = {lib, ...}: {
            imports = [
              inputs.self.modules.darwin.macos-homebrew
              # inputs.self.modules.darwin.macos-mas
            ];
            config = lib.mkIf (host.primaryUser != null) {
              # Brew needs a primary user set
              homebrew.user = host.primaryUser;
              # TODO: This feature comes in 26.11 nix-darwin
              # programs.mas.user = host.primaryUser;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.darwin = {
    macos-homebrew = {...}: {
      key = "macos-homebrew#darwin";
      config = {
        # Enable homebrew
        homebrew = {
          enable = true;
          # Add to path
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          # Also allow managing app store installations
          # TODO: not needed, remove in 26.11
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
            # Trigger brew's auto upgrades when invoking system generation
            autoUpdate = true;
            upgrade = true;
            # On activation, uninstall casks that were installed outside nix
            cleanup = "uninstall";
            # Leave associated files around, "zap" would remove the files too
            # TODO: brew refuses to do cleanup w/out either force, force-cleanup or HOMEBREW_ASK
            # cleanup = "uninstall";
            # Upgrade installed apps
          };
        };
      };
    };
    # TODO: This module exists in darwin 26.11 branch right now only
    macos-mas = {...}: {
      key = "macos-mas#darwin";
      config = {
        # Enable mas
        programs.mas = {
          enable = true;
          # Manage app store apps through flake
          cleanup = true;
          # Run update on system activation
          update = true;
        };
      };
    };
  };
}
