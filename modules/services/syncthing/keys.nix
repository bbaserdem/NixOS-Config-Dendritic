# Syncthing; file synching solution
{inputs, ...}: {
  flake.modules = {
    # Syncthing key dispatching setup

    # For home-manager standalone only, dispatch keys
    homeManager.syncthing = {
      lib,
      config,
      options,
      ...
    } @ args: {
      config =
        lib.optionalAttrs (
          (lib.hasAttrByPath ["sops" "secrets"] options)
          (lib.hasAttrByPath ["networking" "hostName"] options)
          && (! (lib.hasAttrByPath ["osConfig"] args))
        )
        {
          # Setup keys
          sops.secrets = let
            hmKeyConfig = {
              sopsFile = inputs.self + /secrets/host/${config.networking.hostName}/secrets.yaml;
              mode = "0440";
            };
          in {
            "syncthing/key" = hmKeyConfig;
            "syncthing/cert" = hmKeyConfig;
            "syncthing/restapi" = hmKeyConfig;
          };
          # Set the keys
          services.syncthing = {
            key = config.sops.secrets."syncthing/key".path;
            cert = config.sops.secrets."syncthing/cert".path;
            # apiKey = config.sops.secrets."syncthing/restapi".path;
          };
        };
    };

    # For NixOS, dispatch keys with proper ownership
    nixos.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) {
        # Pull keys
        sops.secrets = let
          nixosKeyConfig = {
            owner = config.services.syncthing.user;
            group = config.services.syncthing.group;
            mode = "0440";
          };
        in {
          "syncthing/key" = nixosKeyConfig;
          "syncthing/cert" = nixosKeyConfig;
          "syncthing/restapi" = nixosKeyConfig;
        };
        services.syncthing = {
          # Setup services
          cert = config.sops.secrets."syncthing/cert".path;
          key = config.sops.secrets."syncthing/key".path;
          # https://github.com/NixOS/nixpkgs/pull/401900#event-23372654453
          # apiKeyFile = config.sops.secrets."syncthing/restapi".path;
        };
      };
    };

    # Darwin module keys
    darwin.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) (
        lib.mkMerge [
          {
            # Provision keys to system with correct permissions
            sops.secrets = let
              darwinKeyOwnership = {
                # sopsFile should default to user's host name
                group = "staff";
                mode = "0440";
              };
            in {
              "syncthing/key" = darwinKeyOwnership;
              "syncthing/cert" = darwinKeyOwnership;
              "syncthing/restapi" = darwinKeyOwnership;
            };
          }
          (
            # Dispatch the keys to main users' syncthing configuration
            lib.optionalAttrs (
              (lib.hasAttrByPath ["home-manager"] options)
              && (lib.hasAttrByPath ["local" "mainUser"] options)
            ) {
              home-manager.users = lib.mkIf (config.local.mainUser != null) {
                "${config.local.mainUser}".imports = [
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
            }
          )
        ]
      );
    };
  };
}
