# Dispatch keys to syncthing hosts
{
  lib,
  den,
  inputs,
  ...
}: {
  den = {
    aspects.syncthing = {
      includes = [
        den.aspects.syncthing.keysHost
        den.aspects.syncthing.keysHome
      ];

      provides = {
        # Aspect for running syncthing on nixos and darwin
        keysHost = {host, ...} @ ctx:
          lib.optionalAttrs (!(ctx ? home)) {
            # Nixos; run as system module
            nixos = {
              options,
              lib,
              config,
              ...
            }: {
              # Import settings module
              imports = [
                inputs.self.modules.nixos.syncthing-keys
              ];
              # Load the secrets
              config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) {
                sops.secrets = let
                  nixosKeyConfig = {
                    inherit (host.secrets) sopsFile;
                    owner = config.services.syncthing.user;
                    group = config.services.syncthing.group;
                    mode = "0440";
                  };
                in {
                  "syncthing/key" = nixosKeyConfig;
                  "syncthing/cert" = nixosKeyConfig;
                  "syncthing/restapi" = nixosKeyConfig;
                };
              };
            };

            # Darwin, dispatch to primaryUsers' home-manager
            darwin = {
              options,
              lib,
              ...
            }: {
              # Import settings module
              imports = [
                inputs.self.modules.darwin.syncthing-keys
              ];
              # Load the secrets
              config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) {
                sops.secrets = let
                  darwinKeyOwnership = {
                    inherit (host.secrets) sopsFile;
                    owner = "root";
                    group = "staff";
                    mode = "0440";
                  };
                in {
                  "syncthing/key" = darwinKeyOwnership;
                  "syncthing/cert" = darwinKeyOwnership;
                  "syncthing/restapi" = darwinKeyOwnership;
                };
              };
            };
          };

        # Aspect for running syncthing on standalone home-manager
        keysHome = {home}: {
          homeManager = {
            options,
            lib,
            ...
          }: {
            imports = [
              inputs.self.modules.homeManager.syncthing-keys
            ];
            config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) {
              sops.secrets = let
                hmKeyConfig = {
                  inherit (home.secrets) sopsFile;
                  mode = "0440";
                };
              in {
                "syncthing/key" = hmKeyConfig;
                "syncthing/cert" = hmKeyConfig;
                "syncthing/restapi" = hmKeyConfig;
              };
            };
          };
        };
      };
    };
  };

  flake.modules = {
    # Syncthing key importing module
    nixos.syncthing-keys = {
      config,
      options,
      lib,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) {
        services.syncthing = {
          # Setup services
          cert = config.sops.secrets."syncthing/cert".path;
          key = config.sops.secrets."syncthing/key".path;
          # https://github.com/NixOS/nixpkgs/pull/401900#event-23372654453
          # apiKeyFile = config.sops.secrets."syncthing/restapi".path;
        };
      };
    };

    # Syncthing key importing module for darwin
    darwin.syncthing-keys = {
      config,
      options,
      lib,
      ...
    }: {
      config =
        lib.optionalAttrs (
          (lib.hasAttrByPath ["sops" "secrets"] options)
          && (lib.hasAttrByPath ["home-manager"] options)
        ) {
          home-manager.users = lib.mkIf (config.system.primaryUser != null) {
            "${config.system.primaryUser}".imports = [
              (
                {osConfig, ...}: {
                  services.syncthing = {
                    key = osConfig.sops.secrets."syncthing/key".path;
                    cert = osConfig.sops.secrets."syncthing/cert".path;
                    # apiKey = osConfig.sops.secrets."syncthing/restapi".path;
                  };
                }
              )
            ];
          };
        };
    };

    homeManager.syncthing-keys = {
      lib,
      config,
      options,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) {
        # Set the keys
        services.syncthing = {
          key = config.sops.secrets."syncthing/key".path;
          cert = config.sops.secrets."syncthing/cert".path;
          # apiKey = config.sops.secrets."syncthing/restapi".path;
        };
      };
    };
  };
}
