# Geoclue; location services in nixos
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Define host schema option that allows the type dispatch
    schema.host = {
      includes = [
        den.aspects.desktops.policies.desktop-geolocation-dispatch
      ];
      imports = [
        {
          options = {
            geolocation = lib.mkOption {
              description = "Geolocation related metadata";
              default = {};
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    description = "Enable geoclue on this host";
                    default = false;
                    type = lib.types.bool;
                  };
                  backend = lib.mkOption {
                    description = ''
                      Backend to use for geolocation in geoclue
                      null (default) leaves defaults
                      google uses a google/geoclue-api-key
                      manual needs location.{latitude,longitude,altitude,accuracy}
                    '';
                    default = null;
                    type = lib.types.nullOr (lib.types.enum [
                      "google"
                      "manual"
                    ]);
                  };
                };
              };
            };
          };
        }
      ];
    };

    aspects.desktop = {
      policies.desktop-geolocation-dispatch = {host, ...}: let
        geo = host.geolocation;
      in (
        lib.optionals
        geo.enable
        (
          [
            (den.lib.policy.include den.aspects.desktop._.geolocation)
          ]
          ++ (
            lib.optional
            (geo.backend != null)
            (den.lib.policy.include den.aspects.desktop._.geolocation._.${geo.backend})
          )
        )
      );

      # Aspects import the necessary modules
      provides.geolocation = {
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.geoclue-settings
          ];
        };
        provides.google = {
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.geoclue-google
            ];
          };
        };
        provides.manual = {
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.geoclue-manual
            ];
          };
        };
      };
    };
  };

  # Module that enables geoclue
  flake.modules.nixos = {
    geoclue-settings = {...}: {
      key = "geoclue-settings#nixos";
      config = {
        services.geoclue2 = {
          enable = true;
          # Common apps to allow
          appConfig = {
            redshift = {
              isAllowed = true;
              isSystem = false;
            };
            gammastep = {
              isAllowed = true;
              isSystem = false;
            };
          };
        };
      };
    };

    # Module that enables google services in geoclue
    # Needs api secrets in global accessible secrets/secrets.yaml
    geoclue-google = {
      lib,
      options,
      config,
      ...
    }: {
      key = "geoclue-google#nixos";
      config = lib.optionalAttrs (options ? sops) {
        sops = {
          # Load the secret into userspace
          secrets."google/geoclue-api-key" = {
            sopsFile = inputs.self + /secrets/secrets.yaml;
            owner = "root";
            group = "root";
            mode = "0400";
          };
          # Create template file to be added to geoclue config
          templates."geoclue-google.conf" = {
            owner = "root";
            group = "geoclue";
            mode = "0440";
            restartUnits = ["geoclue.service"];
            content = ''
              [wifi]
              enable=true
              url=https://www.googleapis.com/geolocation/v1/geolocate?key=${config.sops.placeholder."google/geoclue-api-key"}
            '';
          };
        };
        # Pull in geoclue config
        environment.etc."geoclue/conf.d/98-google.conf".source =
          config.sops.templates."geoclue-google.conf".path;
        # Restart geoclue on secrets load
        systemd.services.geoclue = {
          after = ["sops-install-secrets.service"];
          requires = ["sops-install-secrets.service"];
        };
      };
    };

    # Module that configures physical location in geoclue
    # Needs api secrets in host's sops file location/{latitude,longitude}
    geoclue-manual = {
      lib,
      options,
      config,
      ...
    }: {
      key = "geoclue-manual#nixos";
      config = lib.optionalAttrs (options ? sops) {
        sops = let
          geoKeys = [
            "latitude"
            "longitude"
            "altitude"
            "accuracy"
          ];
        in {
          # Load the secret into userspace
          secrets =
            geoKeys
            |> lib.map (k:
              lib.nameValuePair
              "location/${k}"
              {
                owner = "root";
                group = "root";
                mode = "0400";
                restartUnits = ["geoclue.service"];
              })
            |> builtins.listToAttrs;
          # Create template file to replace geoclue static files
          templates."geoclue/geolocation" = {
            owner = "root";
            group = "geoclue";
            mode = "0440";
            restartUnits = ["geoclue.service"];
            content =
              geoKeys
              |> lib.map (k: "${config.sops.placeholder."location/${k}"}")
              |> builtins.concatStringsSep "\n";
          };
        };
        # Enable static location for geoclue
        services.geoclue2 = {
          enableStatic = true;
          # Placeholder values needed; we overwrite this
          staticLatitude = 0.0;
          staticLongitude = 0.0;
          staticAltitude = 0.0;
          staticAccuracy = 0.0;
        };
        # Override the file geoclue generates for static config with our secrets
        environment.etc.geolocation = {
          source = lib.mkForce config.sops.templates."geoclue/geolocation".path;
          mode = lib.mkForce "symlink";
        };
        # Restart geoclue on secrets load
        systemd.services.geoclue = {
          after = ["sops-install-secrets.service"];
          requires = ["sops-install-secrets.service"];
        };
      };
    };
  };
}
