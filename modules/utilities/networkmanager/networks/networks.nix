# Dispatch network configuration using secrets
{
  config,
  lib,
  ...
}: let
  nmCfg = config.localConfig.network-manager;
  nmLib = config.flake.lib;

  wifiSops = nmCfg.secretsFile;
  wifiJson = builtins.fromJSON (builtins.readFile wifiSops);
  templates = nmCfg.templates;
  templateNames = builtins.attrNames templates;

  networksFor = templateName: wifiJson.${templateName} or {};
  namesFor = templateName: builtins.attrNames (networksFor templateName);

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

  profileIdOf = profile: nmLib.nm-profileId profile.templateName profile.name;
  secretKeyOf = profile: field: nmLib.nm-secretKey profile.templateName profile.name field;
  envTokenOf = profile: field: nmLib.nm-envToken profile.templateName profile.name field;
  envRefOf = profile: field: nmLib.nm-envRef profile.templateName profile.name field;
  requiredFor = template: lib.unique (template.requiredFields ++ template.envFields);
  invalidTemplateNames = builtins.filter (name: (!(nmLib.nm-validHandle name))) templateNames;
  invalidNetworkHandles =
    lib.concatMap (
      templateName:
        map (name: "${templateName}/${name}") (
          builtins.filter (name: (!(nmLib.nm-validHandle name))) (namesFor templateName)
        )
    )
    templateNames;
  invalidHandles = invalidTemplateNames ++ invalidNetworkHandles;
  profileIds = map profileIdOf profiles;
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
  flake.modules.nixos.utility-networkmanager = {
    config,
    options,
    lib,
    ...
  }: let
  in {
    config =
      lib.optionalAttrs (
        # Only can load this if SOPS is enabled
        (lib.hasAttrByPath ["sops"] options)
        && (profiles != [])
      ) {
        # Assertions, checking validity of JSON
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

        # Network Manager
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

        # Hook restarts on secrets change
        systemd.services = {
          NetworkManager-ensure-profiles.after = ["sops-install-secrets.service"];
        };
      };
  };
}
