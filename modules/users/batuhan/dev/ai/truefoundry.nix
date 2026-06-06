# Configuring truefoundry credentials
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        local.sopsEnv = {
          TFY_API_KEY = "truefoundry/api";
          TFY_GATEWAY_URL = "truefoundry/url";
        };
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) {
          sops.secrets = let
            cfg = {sopsFile = inputs.self + /secrets/user/secrets.yaml;};
          in {
            "truefoundry/api" = cfg;
            "truefoundry/url" = cfg;
          };
        }
      )
    ];
  };
}
