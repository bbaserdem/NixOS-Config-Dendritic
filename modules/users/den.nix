# User entity registry for den
{
  config,
  lib,
  den,
  ...
}: let
  schemaLib = (inputs.den.lib {inherit inputs lib config;}).schema;
in {
  options = {
    den.users =
      den.lib.schema.mkInstanceRegistry
      config.den.schema.user
      {
        strict = false;
        description = "Canonical user entities";

        extraModules = [
          (
            {name, ...}: {
              options = {
                userName = lib.mkOption {
                  type = lib.types.str;
                  default = name;
                  description = "User account name";
                };
                aspect = lib.mkOption {
                  type = lib.types.raw;
                  default = config.den.aspects.${name} or {};
                  description = "Aspect that configures this canonical user";
                };
              };
            }
          )
        ];
      };
  };
}
