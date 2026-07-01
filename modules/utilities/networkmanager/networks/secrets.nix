# Render NetworkManager Wi-Fi secrets into an environment file
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

  secretKeyOf = profile: field:
    nmLib.nm-secretKey profile.templateName profile.name field;

  envTokenOf = profile: field:
    nmLib.nm-envToken profile.templateName profile.name field;

  fieldsFor = template:
    lib.unique template.envFields;
in {
  flake.modules.nixos.utility-networkmanager = {
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
        sops = {
          secrets = builtins.listToAttrs (
            lib.concatMap (
              profile:
                map (
                  field:
                    lib.nameValuePair (secretKeyOf profile field) {
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

        systemd.services.NetworkManager-ensure-profiles.after = [
          "sops-install-secrets.service"
        ];
      };
  };
}
