# Fonts to install to system with desktop
{
  inputs,
  den,
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
        # For standalone home and nixos; turn on the desktop portal in linux
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
          name = "desktop/xdg(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.xdg-settings
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

  flake.modules = let
    fontPackages = {
      pkgs,
      lib,
      ...
    }:
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
          fira-code
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
    darwin.desktop-fonts = {
      pkgs,
      lib,
      ...
    }: {
      key = "desktop-fonts#darwin";
      config = {
        homebrew.casks = [
        ];
        fonts.packages = fontPackages {inherit pkgs lib;};
      };
    };
    # Install fonts to nixos
    nixos.desktop-fonts = {
      pkgs,
      lib,
      ...
    }: {
      key = "desktop-fonts#nixos";
      config = {
        environment.systemPackages = fontPackages {inherit pkgs lib;};
      };
    };
    # Install to user as well
    homeManager.desktop-fonts = {
      pkgs,
      lib,
      ...
    }: {
      key = "desktop-fonts#homeManager";
      config = {
        home.packages = fontPackages {inherit pkgs lib;};
      };
    };
  };
}
