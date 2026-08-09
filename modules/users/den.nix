# User entity registry for den
{
  config,
  lib,
  den,
  ...
}: {
  options = {
    # den.users =
    #   den.lib.schema.mkInstanceRegistry
    #   config.den.schema.user
    #   {
    #     strict = false;
    #     description = "Canonical user entities";
    #
    #     extraModules = [
    #     ];
    #   };
  };

  config = {
  };
}
