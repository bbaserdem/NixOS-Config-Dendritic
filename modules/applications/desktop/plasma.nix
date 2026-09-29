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
        name = "desktop/plasma";
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

  # Inject package in linux to dump plasma config;
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: {
    packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      plasmaDump = pkgs.writeShellApplication {
        name = "plasmaDump";
        runtimeInputs = [
          inputs.plasma-manager.packages.${system}.rc2nix
          pkgs.coreutils
        ];

        text = ''
          set -euo pipefail

          out_dir="$PWD"
          rc2nix_args=()

          while [ "$#" -gt 0 ]; do
            case "$1" in
              --output-dir)
                if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                  printf 'error: --output-dir requires a directory\n' >&2
                  exit 2
                fi
                out_dir="$2"
                shift 2
                ;;
              --output-dir=*)
                out_dir="''${1#--output-dir=}"
                if [ -z "$out_dir" ]; then
                  printf 'error: --output-dir cannot be empty\n' >&2
                  exit 2
                fi
                shift
                ;;
              --)
                shift
                rc2nix_args+=("$@")
                break
                ;;
              *)
                rc2nix_args+=("$1")
                shift
                ;;
            esac
          done

          mkdir -p "$out_dir"

          timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
          out="$out_dir/plasma-dump_$timestamp.nix"

          rc2nix "''${rc2nix_args[@]}" > "$out"

          printf 'Settings export created at: %s\n' "$(realpath "$out")"
        '';
      };
    };
  };
}
