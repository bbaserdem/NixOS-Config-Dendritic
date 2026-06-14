# Gnome configuration
{...}: {
  flake.modules = {
    # Nixos level settings
    nixos = {
      # Enable global gnome and gdm theming
      stylix = {...}: {
        stylix.targets = {
          gnome-text-editor.enable = true;
          gtksourceview.enable = true;
        };
      };
      # Gnome settings for nixos
      gnome = {
        lib,
        pkgs,
        ...
      }: {
        services = {
          # Enable gnome
          desktopManager.gnome.enable = true;
          # Some gnome services
          gnome = {
            at-spi2-core.enable = true;
            core-apps.enable = true;
            core-developer-tools.enable = true;
            core-os-services.enable = true;
            core-shell.enable = true;
            evolution-data-server.enable = lib.mkForce false;
            games.enable = false;
            gcr-ssh-agent.enable = false;
            glib-networking.enable = true;
            gnome-browser-connector.enable = true;
            gnome-initial-setup.enable = false;
            gnome-keyring.enable = false;
            gnome-online-accounts.enable = false;
            gnome-remote-desktop.enable = true;
            gnome-settings-daemon.enable = true;
            gnome-software.enable = false;
            gnome-user-share.enable = false;
            localsearch.enable = false;
            rygel.enable = false;
            sushi.enable = true;
            tinysparql.enable = false;
          };
        };

        # Exclude packages
        environment.gnome.excludePackages = with pkgs; [
          # Adapt from https://gitlab.gnome.org/GNOME/gnome-build-meta/blob/gnome-48/elements/core/meta-gnome-core-shell.bst
          gnome-tour
          # Core Apps
          epiphany
          gnome-console
          gnome-music
          # Core Developer Tools
          gnome-builder
        ];

        # Install extensions
        environment.systemPackages = with pkgs; [
          gnome-tweaks
          gnome-shell-extensions
        ];
      };
    };

    # Home-manager settings
    homeManager = {
      # Stylix for gnome
      stylix = {
        lib,
        pkgs,
        ...
      }: {
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          stylix.targets = {
            gnome = {
              enable = true;
              colors.enable = true;
              fonts.enable = true;
              image.enable = true;
              inputs.enable = true;
              polarity.enable = true;
            };
            gtksourceview = {
              enable = true;
              colors.enable = true;
            };
            gnome-text-editor.enable = true;
          };
        };
      };

      # Configuring gnome
      gnome = {
        lib,
        pkgs,
        ...
      }: {
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          # Some gnome extensions
          programs.gnome-shell = {
            enable = true;
            extensions = with pkgs.gnomeExtensions; [
              # Status tray
              {package = appindicator;}
              # Battery of wireless devices shown
              {package = wireless-hid;}
              # Menu for removable drives
              {package = removable-drive-menu;}
              # Shows system resources
              {package = system-monitor;}
              # Clipboard
              {package = clipboard-indicator;}
            ];
          };
        };
      };
    };
  };
}
