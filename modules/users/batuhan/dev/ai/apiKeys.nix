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
      ANTHROPIC_API_KEY = "anthropic/api";
      CURSOR_API_KEY = "cursor/api";
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
