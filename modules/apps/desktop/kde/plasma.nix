# Plasma desktop for nixos
{inputs, ...}: {
  flake-file.inputs = {
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        home-manager.follows = "home-manager";
      };
    };
  };

  flake.modules = {
    # NixOS settings
    nixos.kde = {pkgs, ...}: {
      # Enable plasma
      services.desktopManager.plasma6 = {
        enable = true;
      };
      environment = {
        # Exclude packages
        plasma6.excludePackages = with pkgs.kdePackages; [
          # Packages to NOT include
        ];
        # Include some plasma packages
        systemPackages = with pkgs.kdePackages; [
          marble # Maps
          yakuake # Dropdown terminal
        ];
      };
    };

    homeManager = {
      # Stylix integration for KDE
      stylix = {...}: {
        stylix.targets.kde = {
          enable = true;
          decorations = "org.kde.breeze";
          useWallpaper = true;
          decorationTheme = "";
          applicationStyle = "default";
          widgetStyle = "Breeze";
        };
      };

      # Home-Manager settings
      kde = {
        lib,
        pkgs,
        ...
      }: {
        imports = [
          inputs.plasma-manager.homeModules.plasma-manager
        ];
        config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          # TODO: Declarative configuration
        };
      };
    };
  };
}
