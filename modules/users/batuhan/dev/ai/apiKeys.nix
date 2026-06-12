# Configuring truefoundry credentials
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    ...
  }: let
    keys = {
      TFY_API_KEY = "truefoundry/api";
      TFY_GATEWAY_URL = "truefoundry/url";
      OPENAI_API_KEY = "openai/api";
      ANTHROPIC_API_KEY = "anthropic/api_0";
      ANTHROPIC_API_KEY_BACKUP = "anthropic/api_1";
      CURSOR_API_KEY = "cursor/api";
      CONTEXT7_API_KEY = "context7/api";
    };
  in {
    config = lib.mkMerge [
      {
        local.sopsEnv = keys;
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
          sops.secrets =
            keys
            |> lib.mapAttrs' (_: sopsName: {
              name = sopsName;
              value = {
                sopsFile = inputs.self + /secrets/user/secrets.yaml;
              };
            });
        }
      )
    ];
  };
}
