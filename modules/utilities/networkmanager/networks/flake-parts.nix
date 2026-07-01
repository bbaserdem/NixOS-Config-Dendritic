# Entry point for dispatching network configurations
{
  inputs,
  lib,
  ...
}: {
  # Common functions used for parsing
  # We want these functions to refer to each other; scope them in the let in binding
  config = {
    flake.lib = let
      # Get normalized profile name from template type
      profileId = kind: name:
        if lib.hasPrefix "${kind}-" name
        then lib.removePrefix "${kind}-" name
        else name;

      # Get the secret navigation path from JSON
      secretKey = kind: name: field: "${kind}/${name}/${field}";

      # Normalized name reference for env files
      envToken = kind: name: field: "NM_WIFI_${lib.toUpper (builtins.replaceStrings ["-" " "] ["_" "_"] (profileId kind name))}_${lib.toUpper field}";
      envRef = kind: name: field: "$" + (envToken kind name field);

      # Handle validator
      validHandle = name: builtins.match "[A-Za-z0-9 _-]+" name != null;
    in {
      nm-profileId = profileId;
      nm-secretKey = secretKey;
      nm-envToken = envToken;
      nm-envRef = envRef;
      nm-validHandle = validHandle;
    };
  };

  # localConfig option definitions
  options = {
    localConfig.network-manager = let
      templateType = lib.types.submodule {
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
      };
    in {
      secretsFile = lib.mkOption {
        type = lib.types.path;
        default = inputs.self + /secrets/wifi.json;
        description = "SOPS-encrypted JSON file containing Wi-Fi profile fields.";
      };

      envFile = lib.mkOption {
        type = lib.types.str;
        default = "networkmanager-wifi.env";
        description = "Filename for the environment variables.";
      };

      templates = lib.mkOption {
        type = lib.types.attrsOf templateType;
        default = {};
        description = "NetworkManager profile templates.";
      };
    };
  };
}
