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
        # Enable gnome
        desktopManager.gnome.enable = true;
        # Add udev packages
        udev.packages = with pkgs; [
          gnome-settings-daemon
        ];
        # Install profiler on the system level
        sysprof.enable = lib.mkOverride 1400 true;
        gnome.gnome-browser-connector.enable = true;
        # Exclude packages
        environment.gnome.excludePackages = with pkgs; [
          gnome-photos
          gnome-tour
          gedit
          cheese
          gnome-music
          gnome-terminal
          epiphany
          geary
          evince
          gnome-characters
          totem
          tali
          iagno
          hitori
          atomix
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
            eog = {
              enable = true;
              colors.enable = true;
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
