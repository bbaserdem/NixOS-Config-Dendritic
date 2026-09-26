# Plasma desktop for nixos
{inputs, ...}: {
  # Flake input: plasma manager
  flake-file.inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };
  };

  den = {
    aspects.desktop = {
      provides.plasma = {
        # OS level dispatch
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.plasma-settings
          ];
        };
        # User config
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/plasma(${user.userName}@${host.name})";
          # Home-manager module
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.plasma-settings
            ];
          };
          # Stylix default config
          stylix = {lib, ...}: {
            targets = {
              kde = {
                enable = lib.mkDefault true;
                decorations = lib.mkDefault "org.kde.breeze";
                useWallpaper = lib.mkDefault true;
                decorationTheme = lib.mkDefault "";
                applicationStyle = lib.mkDefault "default";
                widgetStyle = lib.mkDefault "Breeze";
              };
              # Disable qt theming; breaks plasma
              qt.enable = lib.mkOverride 55 false;
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    nixos.plasma-settings = {pkgs, ...}: {
      key = "plasma-settings#nixos";
      config = {
        # Enable plasma
        services.desktopManager.plasma6 = {
          enable = true;
        };

        # Manage default packages
        environment = {
          # Exclude packages
          plasma6.excludePackages = with pkgs.kdePackages; [
            discover # Don't need software store
          ];
          # Include some plasma packages
          systemPackages = with pkgs.kdePackages; [
            marble # Maps
            yakuake # Dropdown terminal
          ];
        };
      };
    };

    # Home-Manager settings
    homeManager.plasma-settings = {
      lib,
      pkgs,
      ...
    }: {
      key = "plasma-settings#homeManager";
      imports = [
        inputs.plasma-manager.homeModules.plasma-manager
      ];
      config =
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        };
    };
  };
}
