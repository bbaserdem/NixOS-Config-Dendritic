# Configuring truefoundry credentials
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    config,
    options,
    ...
  }: {
    config = lib.optionalAttrs (lib.hasAttrByPath ["sops"] options) lib.mkMerge [
      {
        sops.secrets = let
          cfg = {sopsFile = inputs.self + /secrets/user/secrets.yaml;};
        in {
          "truefoundry/api" = cfg;
          "truefoundry/url" = cfg;
        };
      }
      (
        lib.mkIf (
          (lib.hasAttrByPath ["sops" "secrets" "truefoundry/api"] config)
          && (lib.hasAttrByPath ["sops" "secrets" "truefoundry/api"] config)
        ) (lib.mkMerge [
          (
            lib.mkIf (config.programs.zsh.enable) {
              programs.zsh.initContent = lib.mkOrder 2000 ''
                #--START--ZSH load TrueFoundry env vars
                if [ -f '${config.sops.secrets."truefoundry/api".path}' ] ; then
                  export TFY_API_KEY="$(cat '${config.sops.secrets."truefoundry/api".path}')"
                fi
                if [ -f '${config.sops.secrets."truefoundry/url".path}' ] ; then
                  export TFY_GATEWAY_URL="$(cat '${config.sops.secrets."truefoundry/url".path}')"
                fi
                #--END--ZSH load TrueFoundry env vars
              '';
            }
          )
          (
            lib.mkIf (config.programs.zsh.enable) {
              programs.bash.bashrcExtra = lib.mkOrder 2000 ''
                #--START--BASH load TrueFoundry env vars
                if [ -f '${config.sops.secrets."truefoundry/api".path}' ] ; then
                  export TFY_API_KEY="$(cat '${config.sops.secrets."truefoundry/api".path}')"
                fi
                if [ -f '${config.sops.secrets."truefoundry/url".path}' ] ; then
                  export TFY_GATEWAY_URL="$(cat '${config.sops.secrets."truefoundry/url".path}')"
                fi
                #--END--BASH load TrueFoundry env vars
              '';
            }
          )
          (
            lib.mkIf (config.programs.fish.enable) {
              programs.fish.shellInitLast = lib.mkOrder 2000 ''
                #--START--FISH load TrueFoundry env vars
                if test -f "${config.sops.secrets."truefoundry/api".path}"
                  set -gx TFY_API_KEY (cat "${config.sops.secrets."truefoundry/api".path}")
                end
                if test -f "${config.sops.secrets."truefoundry/url".path}"
                  set -gx TFY_GATEWAY_URL (cat "${config.sops.secrets."truefoundry/url".path}")
                end
                #--END--FISH load TrueFoundry env vars
              '';
            }
          )
          (
            lib.mkIf (config.programs.nushell.enable) {
              programs.nushell.envFile = lib.mkOrder 2000 ''
                #--START--NUSHELL load TrueFoundry env vars
                let api_path = "${config.sops.secrets."truefoundry/api".path}"
                if ($api_path | path exists) {
                    $env.TFY_API_KEY = (open $api_path | str trim)
                }
                let url_path = "${config.sops.secrets."truefoundry/url".path}"
                if ($url_path | path exists) {
                    $env.TFY_GATEWAY_URL = (open $url_path | str trim)
                }
                #--END--NUSHELL load TrueFoundry env vars
              '';
            }
          )
        ])
      )
    ];
  };
}
