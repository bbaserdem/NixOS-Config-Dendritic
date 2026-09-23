# Gnome configuration
{inputs, ...}: {
  den = {
    # Our aspect
    aspects.desktop = {
      provides.gnome = {
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.gnome-settings
          ];
        };
        # User-based config
        provides.to-users = {
          host,
          user,
        }: {
          name = "desktop/gnome(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              gnome-settings
              gnome-extensions
              gnome-behavior
            ];
          };
          stylix = {
            targets = {
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
      };
    };
  };

  # Modules
  flake.modules = {
    # Nixos level settings
    nixos.gnome-settings = {
      lib,
      pkgs,
      options,
      ...
    }: {
      key = "gnome-settings#nixos";
      config = lib.mkMerge [
        {
          services = {
            # Enable gnome
            desktopManager.gnome.enable = true;
            # Some gnome services
            gnome = {
              # Core modules that is useful to have
              at-spi2-core.enable = true;
              core-apps.enable = true;
              core-developer-tools.enable = true;
              core-os-services.enable = true;
              core-shell.enable = true;
              glib-networking.enable = true;
              gnome-keyring.enable = true;
              gnome-settings-daemon.enable = true;
              # Integrate with external accounts; and internal tooling
              gnome-online-accounts.enable = true;
              evolution-data-server.enable = true;
              gnome-browser-connector.enable = true;
              # Local indexing
              localsearch.enable = true;
              tinysparql.enable = true;
              sushi.enable = true;
              # Content streaming
              gnome-remote-desktop.enable = true; # only wayland rdp afaik
              rygel.enable = lib.mkForce false; # Stream to local media broadcasting
              # Unneeded fluff
              games.enable = false;
              gnome-initial-setup.enable = false;
              gcr-ssh-agent.enable = false; # We use gpg-agent as the ssh-agent
              gnome-user-share.enable = false; # We use samba for file sharing
              gnome-software.enable = false; # No flatpak/imperative mutation
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
        }
        (
          # Some nix-only stylix targets
          lib.optionalAttrs (options ? stylix) {
            stylix.targets = {
              gnome-text-editor.enable = true;
              gtksourceview.enable = true;
            };
          }
        )
      ];
    };

    # Home-manager settings
    homeManager = {
      # Main enable
      gnome-settings = {
        lib,
        pkgs,
        ...
      }: {
        key = "gnome-settings#homeManager";
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          # Enable gnome shell
          programs.gnome-shell = {
            enable = true;
          };
        };
      };
      # Base extensions
      gnome-extensions = {
        lib,
        pkgs,
        ...
      }: {
        key = "gnome-extensions#homeManager";
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          # Some gnome extensions
          programs.gnome-shell = {
            extensions = with pkgs.gnomeExtensions; [
              # Status tray
              {package = appindicator;}
              # Battery of wireless devices shown
              {package = wireless-hid;}
              # Menu for removable drives
              {package = removable-drive-menu;}
              # Shows system resources
              {package = vitals;}
              # Clipboard
              {package = clipboard-indicator;}
              # MacOS like dock
              {package = dash2dock-lite;}
              # UI candy for top bar
              {package = open-bar;}
              # Tiling
              {package = tiling-shell;}
              # mpdris media controls
              {package = media-controls;}
              {package = dynamic-music-pill;}
            ];
          };
        };
      };
      # Base behavior
      gnome-behavior = {
        lib,
        pkgs,
        ...
      }: {
        key = "gnome-behavior#homeManager";
        config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          # Disable gnome auto-mount behavior
          "org/gnome/desktop/media-handling" = {
            automount = false;
            automount-open = false;
            autorun-never = true;
          };
        };
      };
    };
  };
}
