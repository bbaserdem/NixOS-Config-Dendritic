# Hyprland setup
{...}: {
  flake.modules = {
    # System settings
    nixos.hyprland = {...}: {
      # Enables Hyprland as a session
      programs = {
        hyprland = {
          enable = true;
          withUWSM = true; # Launch with Universal Wayland Session Manager
          xwayland.enable = true;
        };
        hyprlock.enable = true;
        uwsm.enable = true;
      };

      # Hint electron apps to use wayland
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    };

    # Home manager
    homeManager = {
      # Stylix integration
      stylix = {...}: {
        stylix.targets.hyprland = {
          colors.enable = true;
          enable = true;
        };
      };

      # Home-Manager settings
      hyprland = {
        lib,
        pkgs,
        config,
        ...
      } @ args: {
        config = lib.mkMerge [
          (
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              # Enable hyprland
              wayland.windowManager.hyprland = {
                enable = true;
                # Don't do systemd integration, we will do this ourselves
                systemd.enable = false;
              };
              # Systemd fix for uwsm, and env variables for hyprland
              xdg.configFile = {
                # Systemd fix for uwsm
                "uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
                # Env vars for hyprland
                "uwsm/env-hyprland".text = ''
                  export HYPRCURSOR_SIZE=24
                  export QT_QPA_PLATFORMTHEME=qt6ct
                  export QT_QPA_PLATFORM=wayland
                  export QT_IM_MODULE="fcitx"
                  export QT_IM_MODULES="wayland;fcitx;ibus"
                  unset GTK_IM_MODULE
                '';
              };
            }
          )
          (
            # In standalone, set the package and portal to pkgs
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && (!(lib.hasAttrByPath ["osConfig"] args))) {
              wayland.windowManager.hyprland.package = pkgs.hyprland;
              wayland.windowManager.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland;
              wayland.windowManager.hyprland.systemd.enable = true;
            }
          )
          (
            # In nixos, will be brought from nixos context
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && (lib.hasAttrByPath ["osConfig"] args)) {
              wayland.windowManager.hyprland.package = null;
              wayland.windowManager.hyprland.portalPackage = null;
            }
          )
        ];
      };
    };
  };
}
