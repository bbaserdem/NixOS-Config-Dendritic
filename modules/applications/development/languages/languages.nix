# Configuring config for package managers
{
  den,
  lib,
  ...
}: let
  configuredLangs = [
    "python"
    "lean"
    "typescript"
  ];
in {
  # Aspect config
  den = {
    # Schema for declaring host language capabilities
    schema = {
      host = {
        includes = [
          den.aspects.development.policies.languages-host-dispatch
        ];
        options = {
          development = lib.mkOption {
            type = lib.types.submodule {
              options = {
                languages = lib.mkOption {
                  description = "Languages to setup global dev configuration for.";
                  default = "all";
                  type =
                    lib.types.either
                    (lib.types.enum ["all"])
                    (lib.types.listOf (lib.types.enum configuredLangs));
                };
              };
            };
          };
        };
      };
      user.includes = [
        den.aspects.development.policies.languages-user-dispatch
      ];
    };

    aspects.development = {
      # Policy dispatch
      policies = {
        languages-host-dispatch = {host, ...}:
          lib.optionals
          host.development.enable
          (
            [
              (den.lib.policy.include den.aspects.development._.languages)
            ]
            ++ (
              builtins.map
              (
                n: (
                  den.lib.policy.include
                  den.aspects.development._.languages._.${n}
                )
              )
              (
                if (host.development.languages == "all")
                then configuredLangs
                else host.development.languages
              )
            )
          );
        languages-user-dispatch = {host, ...}:
          lib.optionals
          host.development.enable
          (
            [
              (den.lib.policy.include den.aspects.development._.languages._.to-users)
            ]
            ++ (
              builtins.map
              (
                n: (
                  den.lib.policy.include
                  den.aspects.development._.languages._.${n}._.to-users
                )
              )
              (
                if (host.development.languages == "all")
                then configuredLangs
                else host.development.languages
              )
            )
          );
      };

      provides.languages = {
        name = "development/languages";
        provides.to-users = {
          user,
          host,
        }: {
          name = "development/languages(${user.userName}@${host.name})";
        };
      };
    };
  };
}
