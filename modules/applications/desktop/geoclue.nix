# Geoclue; location services in nixos
{inputs, ...}: {
  # Module that enables geoclue
  flake.modules.nixos.geoclue-settings = {...}: {
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
  flake.modules.nixos.geoclue-google = {
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
  flake.modules.nixos.geoclue-manual = {
    lib,
    options,
    config,
    ...
  }: {
    key = "geoclue-manual#nixos";
    config = lib.optionalAttrs (options ? sops) {
      sops = {
        # Load the secret into userspace
        secrets =
          ["latitude" "longitude" "altitude" "accuracy"]
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
          content = ''
            ${config.sops.placeholder."location/latitude"}
            ${config.sops.placeholder."location/longitude"}
            ${config.sops.placeholder."location/altitude"}
            ${config.sops.placeholder."location/accuracy"}
          '';
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
}
