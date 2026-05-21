# Syncthing; file synching solution
{inputs, ...}: {
  flake.modules = {
    # Syncthing setup

    # For home-manager, dispatch keys from parent if they are available
    # Not a problem for nixos, because homeManager syncthing is not enabled
    # In darwin, only the mainUser gets the homeManager.syncthing module, pulls from osConfig
    # In hm-standalone, pulls from config
    homeManager.syncthing = {
      lib,
      config,
      ...
    } @ args: {
      config = lib.mkMerge [
        (
          # Pull info from osConfig if we are hm as a module
          lib.optionalAttrs (lib.hasAttrByPath ["osConfig"] args) (
            lib.mkIf (lib.hasAttrByPath ["sops"] args.osConfig) {
              services.syncthing = {
                key = lib.mkIf (lib.hasAttrByPath ["sops" "secrets" "syncthing/key"] args.osConfig) args.osConfig.sops.secrets."syncthing/key".path;
                cert = lib.mkIf (lib.hasAttrByPath ["sops" "secrets" "syncthing/cert"] args.osConfig) args.osConfig.sops.secrets."syncthing/cert".path;
                # apiKey = lib.mkIf (lib.hasAttrByPath ["sops" "secrets" "syncthing/restapi"] args.osConfig) args.osConfig.sops.secrets."syncthing/restapi".path;
              };
            }
          )
        )
        (
          # Set secrets if standalone, and point to the keys
          lib.mkIf (! (lib.hasAttrByPath ["osConfig"] args))
          {
            # Setup keys
            # TODO: force secret file (host secrets) conventions here
            sops.secrets = {
              "syncthing/key" = {};
              "syncthing/cert" = {};
              "syncthing/restapi" = {};
            };
            # Set the keys
            services.syncthing = {
              key = lib.mkIf (lib.hasAttrByPath ["sops" "secrets" "syncthing/key"] config) config.sops.secrets."syncthing/key".path;
              cert = lib.mkIf (lib.hasAttrByPath ["sops" "secrets" "syncthing/cert"] config) config.sops.secrets."syncthing/cert".path;
              # apiKey = lib.mkIf (lib.hasAttrByPath ["sops" "secrets" "syncthing/restapi"] config) config.sops.secrets."syncthing/restapi".path;
            };
          }
        )
      ];
    };

    # NixOS module; sets key ownership to
    nixos.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) (
        let
          nixosKeyOwnership = {
            owner = "syncthing";
            group = "syncthing";
            mode = "0440";
          };
        in {
          # Setup keys
          sops.secrets = {
            "syncthing/key" = nixosKeyOwnership;
            "syncthing/cert" = nixosKeyOwnership;
            "syncthing/restapi" = nixosKeyOwnership;
          };
          services.syncthing = {
            # Setup services
            cert = config.sops.secrets."syncthing/cert".path;
            key = config.sops.secrets."syncthing/key".path;
            # https://github.com/NixOS/nixpkgs/pull/401900#event-23372654453
            # apiKeyFile = config.sops.secrets."syncthing/restapi".path;
          };
        }
      );
    };

    # Darwin module keys
    darwin.syncthing = {
      config,
      options,
      lib,
      ...
    }: {
      config = lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) (let
        darwinKeyOwnership = {
          group = "staff";
          mode = "0440";
        };
      in {
        # Provision key Ownership, so home-manager can pull it in.
        sops.secrets = {
          "syncthing/key" = darwinKeyOwnership;
          "syncthing/cert" = darwinKeyOwnership;
          "syncthing/restapi" = darwinKeyOwnership;
        };
      });
    };
  };
}
