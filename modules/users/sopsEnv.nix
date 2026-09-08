# Set envoronment variables from sops
{
  lib,
  den,
  inputs,
  ...
}: let
in {
  den = {
    schema.user = {
      imports = [
        ({config, ...}: {
          options = {
            sopsEnv = lib.mkOption {
              description = "Environment secrets auto-loading from sops secrets";
              default = {};
              type = lib.types.submodule {
                options = {
                  enable = lib.mkOption {
                    description = "Enable auto-loading secrets from sops file";
                    default = true;
                    type = lib.types.bool;
                  };
                  sopsFile = lib.mkOption {
                    description = "The JSON file used for the environment files";
                    type = lib.types.path;
                    default = inputs.self + "/secrets/user/${config.name}/environment.json";
                  };
                };
              };
            };
          };
        })
      ];
      includes = [
        den.aspects.sopsEnv.policies.user-sops-env-enable
      ];
    };

    aspects.sopsEnv = {
      # Policy for dispatching
      policies.user-sops-env-enable = {user, ...}:
        lib.optional
        user.sopsEnv.enable
        (den.lib.policy.include den.aspects.sopsEnv._.set-user-env);

      provides.set-user-env = {
        host,
        user,
      }: {
        # Prevent collisions
        name = "sopsEnv/set-user-env(${user.userName}@${host.name})";

        # Load the secrets in home-manager
        homeManager = {
          lib,
          options,
          config,
          pkgs,
          ...
        }: let
          envVars =
            user.sopsEnv.sopsFile
            |> builtins.readFile
            |> builtins.fromJSON
            |> builtins.attrNames
            |> builtins.filter (x: x != "sops");
          invalidEnvVars =
            envVars
            |> builtins.filter (
              s:
                (builtins.match "[A-Za-z_][A-Za-z0-9_]*" s) == null
            );
          shellExports =
            envVars
            |> builtins.map (env: let
              secretPath = lib.escapeShellArg config.sops.secrets.${env}.path;
            in ''
              if [ -r ${secretPath} ]; then
                export ${env}="$(${pkgs.coreutils}/bin/cat ${secretPath})"
              fi
            '')
            |> lib.concatStringsSep "\n";
        in {
          config = lib.optionalAttrs (options ? sops) (
            lib.mkMerge [
              {
                assertions = [
                  {
                    assertion = invalidEnvVars == [];
                    message = ''
                      Invalid sops environment variable names:
                      - ${lib.concatStringsSep "\n- " invalidEnvVars}
                    '';
                  }
                ];

                sops = {
                  # Decrypt all sops secrets
                  secrets = lib.genAttrs envVars (env: {
                    inherit (user.sopsEnv) sopsFile;
                    format = "json";
                    key = env;
                  });
                };
              }
              (
                lib.mkIf config.programs.bash.enable {
                  programs.bash.bashrcExtra = lib.mkOrder 2000 shellExports;
                }
              )
              (
                lib.mkIf config.programs.zsh.enable {
                  programs.zsh.initContent = lib.mkOrder 2000 shellExports;
                }
              )
            ]
          );
        };
      };
    };
  };
}
