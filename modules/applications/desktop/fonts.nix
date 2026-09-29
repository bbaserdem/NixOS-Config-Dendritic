# Fonts to install to systems
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    aspects.desktop = {
      # Load by default
      includes = [
        den.aspects.desktop._.fonts
      ];
      provides.fonts = let
        # Stylix block for nixos and home-manager
        stylixConf = {
          targets = {
            fontconfig = {
              enable = true;
              fonts.enable = true;
            };
            font-packages = {
              enable = true;
              fonts.enable = true;
            };
          };
        };
      in {
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.desktop-fonts
          ];
        };
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.desktop-fonts
          ];
        };
        # Enable stylix for nixos
        stylix = {
          host,
          lib,
          ...
        }:
          lib.mkIf (host.class == "nixos") stylixConf;
        # User dispatch
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/fonts(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.desktop-fonts
            ];
          };
          # Enable stylix font management in linux
          stylix = {
            pkgs,
            lib,
            ...
          }:
            lib.mkIf pkgs.stdenv.hostPlatform.isLinux stylixConf;
        };
      };
    };
  };

  # Modules
  flake.modules = let
    # One function to create the font set to install from pkgs.
    fontPackages = pkgs:
      with pkgs; (
        [
          corefonts # Web rendering fonts
          nerd-fonts.symbols-only
          noto-fonts-monochrome-emoji # Emoji fonts
          noto-fonts-color-emoji
          _3270font # Monospace
          fira-code # Monospace with ligatures
          liberation_ttf # Windows compat.
          caladea #   Office fonts alternative
          carlito #   Calibri/georgia alternative
          inconsolata # Monospace font, for prints
          iosevka # Monospace font, for terminal mostly
          victor-mono
          noto-fonts
          source-code-pro
          source-serif-pro
          source-sans-pro
          curie # Bitmap fonts
          tamsyn
          jetbrains-mono
        ]
        ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          # Broken on nix-darwin right now
        ])
      );
  in {
    # Put fonts into darwin system (using nix-darwin)
    darwin.desktop-fonts = {pkgs, ...}: {
      key = "desktop-fonts#darwin";
      config = {
        homebrew.casks = [
        ];
        fonts.packages = fontPackages pkgs;
      };
    };
    # Install fonts to nixos
    nixos.desktop-fonts = {pkgs, ...}: {
      key = "desktop-fonts#nixos";
      config = {
        environment.systemPackages = fontPackages pkgs;
      };
    };
    # Install to user as well
    homeManager.desktop-fonts = {pkgs, ...}: {
      key = "desktop-fonts#homeManager";
      config = {
        home.packages = fontPackages pkgs;
      };
    };
  };
}
