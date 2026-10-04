{
  inputs,
  lib,
  ...
}: {
  # flake-parts local config options for network manager registry
  options = {
    networkManager = lib.mkOption {
      description = "Fleet-wide config options for using NetworkManager";
      default = {};
      type = lib.types.submodule {
        options = {
          # The sops file to pull from
          secretsFile = lib.mkOption {
            description = "SOPS-encrypted JSON file containing Wi-Fi profile fields.";
            default = inputs.self + /secrets/wifi.json;
            type = lib.types.path;
          };
          # Template type designation
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
          # Operational metadata
          envFile = lib.mkOption {
            description = "Filename for the environment variables.";
            default = "networkmanager-wifi.env";
            type = lib.types.str;
          };
        };
      };
    };
  };
}
