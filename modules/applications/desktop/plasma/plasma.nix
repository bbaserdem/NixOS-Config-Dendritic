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
    # Fix for slow plasma; https://github.com/NixOS/nixpkgs/issues/126590
    # TODO: Track this, remove this if fixed
    laminix = {
      url = "github:jackboykin/laminix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  den = {
    aspects.desktop = {
      provides.plasma = {
        name = "desktop/plasma";
        # OS level dispatch
        nixos = {
          options,
          lib,
          ...
        }: {
          imports = [
            inputs.self.modules.nixos.plasma-settings
            (inputs.laminix.nixosModules.default or {})
          ];
          config = lib.optionalAttrs (options.environment ? laminix) {
            environment.laminix = {
              enable = true;
              plasma = "full";
            };
            # Laminix and fcitx5 are causing issues; this overlay should fix it
            nixpkgs.overlays = [
              (_: prev: {
                qt6Packages = prev.qt6Packages.overrideScope (
                  _: qtPrev: {
                    fcitx5-with-addons = qtPrev.fcitx5-with-addons.overrideAttrs (old: {
                      buildCommand =
                        old.buildCommand
                        + ''
                          target="$(readlink -f "$out/bin/.fcitx5-wrapped")"
                          cp --remove-destination "$target" "$out/bin/.fcitx5-wrapped"
                        '';
                    });
                  }
                );
              })
            ];
          };
        };
        # User config
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/plasma(${user.userName}@${host.name})";
          # Home-manager module
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              plasma-settings
              plasma-defaults
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
        services = {
          desktopManager.plasma6 = {
            enable = true;
          };
          # Disable accessibility feature
          orca.enable = false;
        };
        # Disable plasma bloat
        programs = {
          kde-pim.enable = false;
        };

        # Manage default packages in plasma
        environment = {
          # Exclude some defaults from plasma
          plasma6.excludePackages = with pkgs.kdePackages; [
            discover # Don't need software store
            konsole # Don't want the terminal
            khelpcenter # Don't need KDE documentation
            kate # Don't need the text editor suite
            ktexteditor
            plasma-workspace-wallpapers # Don't need wallpapers
          ];
          # Include some plasma packages
          systemPackages = with pkgs.kdePackages; [
            marble # Maps
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
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        # Inject native messaging hosts to browsers that can be configured
        programs =
          lib.genAttrs
          ["firefox" "librewolf" "chromium"]
          (_: {nativeMessagingHosts = [pkgs.kdePackages.plasma-browser-integration];});
      };
    };
  };
}
