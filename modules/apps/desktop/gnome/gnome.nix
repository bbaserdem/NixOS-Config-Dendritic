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
            rygel.enable = lib.mkDefault false; # Stream to local media broadcasting
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
          # Enable gnome shell
          programs.gnome-shell = {
            enable = true;
          };
        };
      };
    };
  };
}
