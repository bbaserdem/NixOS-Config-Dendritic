# GDM setup for nixos systems
{...}: {
  flake.modules = {
    nixos = {
      gdm = {...}: {
        local.displayManager = "gdm";
        # Setup the GDM config besides the enable option
        services.displayManager.gdm = {
          wayland = true;
        };
      };

      # Stylix theming for configured display managers
      stylix = {...}: {
        # The nixos option themes gdm, not gnome
        stylix.targets.gnome.enable = true;
      };
    };
  };
}
