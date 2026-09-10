# Network-Manager, for network management
{
  inputs,
  lib,
  ...
}: {
  # Main config options
  config = {
    den = {
      # Aspect that sets up network manager
      aspects.networkManager = {
        # Nixos config module
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.networkManager-setup
            inputs.self.modules.nixos.networkManager-endpoints
          ];
        };

        # Set users as networkmanager users; use den dispatch
        provides.to-users = {
          host,
          user,
        }: {
          name = "networkManager/to-users(${user.userName}@${host.name})";
          user = {...}: {
            extraGroups = [
              "networkmanager"
            ];
          };
        };
      };
    };

    # Basic networkmanager settings enable
    flake.modules.nixos.networkManager-setup = {...}: {
      # Enable network manager for networking
      networking.networkmanager.enable = true;
      # Enable timezoned
      services.automatic-timezoned.enable = true;
    };

    # TODO: Delete after den migration
    flake.modules.nixos.utility-networkmanager = {...}: {
      imports = [
        inputs.self.modules.nixos.networkManager-setup
        inputs.self.modules.nixos.networkManager-endpoints
      ];
    };
  };

  # flake-parts localConfig option definitions for network registry
  options = {
    localConfig.network-manager = lib.mkOption {
      description = "Fleet-wide config options for using NetworkManager";
      default = {};
      type = lib.types.submodule {
        options = {
          secretsFile = lib.mkOption {
            description = "SOPS-encrypted JSON file containing Wi-Fi profile fields.";
            default = inputs.self + /secrets/wifi.json;
            type = lib.types.path;
          };
          envFile = lib.mkOption {
            description = "Filename for the environment variables.";
            default = "networkmanager-wifi.env";
            type = lib.types.str;
          };
          templates = lib.mkOption {
            description = "NetworkManager profile templates.";
            default = {};
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  requiredFields = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [];
                    description = "Fields required in the JSON for this template.";
                  };
                  envFields = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    default = [];
                    description = ''
                      Secrets agent can't dispatch everything. (i.e. SSIDs)
                      We will provide these keys with an env file instead.
                    '';
                  };
                  profile = lib.mkOption {
                    type = lib.types.functionTo lib.types.unspecified;
                    description = "Function producing a NetworkManager ensureProfiles profile.";
                  };
                };
              }
            );
          };
        };
      };
    };
  };
}
