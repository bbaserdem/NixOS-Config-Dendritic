# Nix
# TODO: Delete after den migration
{
  inputs,
  config,
  ...
}: {
  flake.modules = let
    localAddress = "system-docs";
  in {
    # Generic; for nix settings for both nixos and darwin contexts
    generic.nix = {pkgs, ...}: {
      config = {
        # Package manager config
        nix = {
          gc.options = "--delete-older-than 60d";
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
              "pipe-operators"
              "ca-derivations"
            ];
            # For dev related things
            keep-outputs = true;
            keep-derivations = true;
          };
        };

        programs = {
          nix-index.enable = true;
          nix-index-database.comma.enable = true;
        };

        # Nix helper utilities
        environment.systemPackages = with pkgs; [
          nh
          nix-output-monitor
          nvd
          sops
          nix-diff
          nix-weather
        ];
      };
    };

    # Nixos module; for nixos specific nix settings
    nixos.nix = {...}: {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];

      config = {
        # Garbage collect settings
        nix = {
          nixPath = ["nixpkgs=${inputs.nixpkgs}"];
          gc.automatic = true;
          settings.auto-optimise-store = true;
        };
        programs = {
          # Linux-specific configuration
          nix-ld.enable = true;
          nix-index = {
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
          };
        };
      };
    };

    # Darwin module; for darwin specific settings
    darwin.nix = {...}: {
      imports = [
        inputs.nix-index-database.darwinModules.nix-index
      ];

      config = {
        nix = {
          nixPath = ["nixpkgs=${inputs.nixpkgs-darwin}"];
          optimise.automatic = true;
          enable = true;
          gc.interval = [
            {
              Hour = 3;
              Minute = 15;
              Weekday = 7;
            }
          ];

          # Enable cross-comp
          linux-builder.enable = true;
          settings.trusted-users = ["@admin"];
        };
      };
    };

    # Home-manager; add nix-index to hm
    homeManager.nix = {...}: {
      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs = {
        nix-index-database.comma.enable = true;
        nix-index = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
        };
      };
    };

    # System docs
    # In nixos, the service is nginx
    nixos.nginx = {pkgs, ...}: {
      networking.hosts."127.0.0.1" = ["${localAddress}.localhost"];

      services.nginx.virtualHosts."${localAddress}.localhost" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 80;
          }
        ];
        root = "${pkgs.local.system-docs}";
        locations."/".tryFiles = "$uri $uri/ $uri.html /index.html";
      };
    };

    # In darwin, the service is caddy
    darwin.caddy-local = {
      lib,
      pkgs,
      ...
    }: {
      services.caddy.virtualHosts."${localAddress}.localhost" = {
        listen = "http://${localAddress}.localhost";
        extraConfig = ''
          bind 127.0.0.1

          root * ${pkgs.local.system-docs}
          try_files {path} {path}/ {path}.html /index.html
          file_server
        '';
      };
      system.activationScripts.postActivation.text = lib.mkAfter ''
        if ! /usr/bin/grep -qE '^[[:space:]]*127[.]0[.]0[.]1[[:space:]].*${localAddress}[.]localhost' /etc/hosts; then
          /bin/echo '127.0.0.1 ${localAddress}.localhost' >> /etc/hosts
        fi
      '';
    };

    # This module is auto-imported by factory functions
    generic.nixpkgs = {...}: {
      config = {
        nixpkgs = {
          inherit (config.nixpkgs) config overlays;
        };
      };
    };
  };
}
