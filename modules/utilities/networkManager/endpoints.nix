# Module to auto-load secrets into network-manager for all systems
{
  config,
  lib,
  ...
}: let
  # Bunch of pre-processing here
  # Load from flake the configs in new namespace (config overridden in module)
  nmCfg = config.localConfig.network-manager;

  # Boilerplate
  # Get normalized profile name from template type
  profileId = kind: name:
    if lib.hasPrefix "${kind}-" name
    then lib.removePrefix "${kind}-" name
    else name;
  # Get the secret navigation path from JSON
  secretKey = kind: name: field: "${kind}/${name}/${field}";
  # Normalized name reference for env files
  envToken = kind: name: field: "NM_WIFI_${
    lib.toUpper
    (builtins.replaceStrings ["-" " "] ["_" "_"] (profileId kind name))
  }_${
    lib.toUpper
    field
  }";
  envRef = kind: name: field: "$" + (envToken kind name field);
  # Handle validator
  validHandle = name: builtins.match "[A-Za-z0-9 _-]+" name != null;

  # Process sops files to obtain secrets
  wifiSops = nmCfg.secretsFile;
  wifiJson =
    wifiSops
    |> builtins.readFile
    |> builtins.fromJSON;
  # Load network setup templates
  templates = nmCfg.templates;
  templateNames = builtins.attrNames templates;
  networksFor = templateName: wifiJson.${templateName} or {};
  namesFor = templateName: builtins.attrNames (networksFor templateName);

  # Create profiles and their env tokens
  profiles =
    lib.concatMap (
      templateName:
        map (name: {
          inherit templateName name;
          template = templates.${templateName};
          data = (networksFor templateName).${name};
        })
        (namesFor templateName)
    )
    templateNames;
  envTokens =
    lib.concatMap (
      profile:
        map (field: envTokenOf profile field) profile.template.envFields
    )
    profiles;

  # Profile processing
  profileIdOf = profile:
    profileId
    profile.templateName
    profile.name;
  secretKeyOf = profile: field:
    secretKey
    profile.templateName
    profile.name
    field;
  envTokenOf = profile: field:
    envToken
    profile.templateName
    profile.name
    field;
  fieldsFor = template:
    lib.unique
    template.envFields;
  envRefOf = profile: field:
    envRef
    profile.templateName
    profile.name
    field;
  requiredFor = template:
    lib.unique
    (template.requiredFields ++ template.envFields);
  invalidTemplateNames =
    builtins.filter
    (name: (!(validHandle name)))
    templateNames;
  invalidNetworkHandles =
    lib.concatMap (
      templateName:
        builtins.map (name: "${templateName}/${name}") (
          builtins.filter
          (name: (!(validHandle name)))
          (namesFor templateName)
        )
    )
    templateNames;
  invalidHandles = invalidTemplateNames ++ invalidNetworkHandles;
  profileIds = builtins.map profileIdOf profiles;
  missingRequired =
    lib.concatMap (
      profile: (
        lib.concatMap (
          field:
            lib.optional (!(builtins.hasAttr field profile.data)) (secretKeyOf profile field)
        )
        (requiredFor profile.template)
      )
    )
    profiles;
in {
  # Wifi secrets loading as flake-parts module
  flake.modules.nixos.networkManager-endpoints = {
    config,
    options,
    lib,
    ...
  }: {
    config =
      lib.optionalAttrs (
        # Can only dispatch with sops; and skip on empty
        (lib.hasAttrByPath ["sops"] options)
        && (profiles != [])
      ) {
        # Check JSON validity
        assertions = [
          {
            # Handle check
            assertion = invalidHandles == [];
            message = ''
              Invalid Wi-Fi handles in wifi.json:
              - ${lib.concatStringsSep "\n- " invalidHandles}
            '';
          }
          {
            # Missing keys check
            assertion = missingRequired == [];
            message = ''
              Missing keys in wifi.json:
              - ${lib.concatStringsSep "\n- " missingRequired}
            '';
          }
          {
            # Duplicate IDs
            assertion = (builtins.length (lib.unique profileIds)) == (builtins.length profileIds);
            message = ''
              Duplicate NetworkManager profile IDs generated in wifi.json
            '';
          }
          {
            # Duplicate env names
            assertion = (builtins.length (lib.unique envTokens)) == (builtins.length envTokens);
            message = ''
              Duplicate NetworkManager environment variable names generated from wifi.json handles.
            '';
          }
        ];

        # Sops dispatch
        sops = {
          # Load all secrets from wifi credentials
          secrets = builtins.listToAttrs (
            lib.concatMap (
              profile:
                builtins.map (
                  field:
                    lib.nameValuePair
                    (secretKeyOf profile field)
                    {
                      sopsFile = wifiSops;
                      # sops-install-secrets currently fails nested path traversal for JSON.
                      # JSON is valid YAML, so use yaml here while still parsing the file with builtins.fromJSON.
                      format = "yaml";
                      key = secretKeyOf profile field;
                      owner = "root";
                      group = "root";
                      mode = "0400";
                    }
                )
                (fieldsFor profile.template)
            )
            profiles
          );
          # Create one env file for systemd to read
          templates.${nmCfg.envFile} = {
            owner = "root";
            group = "root";
            mode = "0400";
            restartUnits = ["NetworkManager-ensure-profiles.service"];
            content =
              lib.concatStringsSep "\n" (
                lib.concatMap (
                  profile:
                    map (
                      field: "${envTokenOf profile field}=\"${config.sops.placeholder.${secretKeyOf profile field}}\""
                    )
                    profile.template.envFields
                )
                profiles
              )
              + "\n";
          };
        };

        # Network Manager settings
        networking.networkmanager.ensureProfiles = {
          # Load the non-agent dispatched environment variables
          environmentFiles = [
            config.sops.templates."${nmCfg.envFile}".path
          ];
          # Load the profile files with network setup
          profiles = builtins.listToAttrs (
            map (
              profile:
                lib.nameValuePair (profileIdOf profile) (
                  profile.template.profile {
                    inherit lib;
                    inherit (profile) name templateName;
                    profileId = profileIdOf profile;
                    network = profile.data;
                    env = field: envRefOf profile field;
                    envToken = field: envTokenOf profile field;
                    secretKey = field: secretKeyOf profile field;
                  }
                )
            )
            profiles
          );
        };

        # Restart the profile manager if SOPS is activated
        systemd.services.NetworkManager-ensure-profiles.after = [
          "sops-install-secrets.service"
        ];
      };
  };
}
