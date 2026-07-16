# setup of den
{
  inputs,
  den,
  ...
}: {
  # Load flake-parts modules
  imports = [
    (inputs.den.flakeModules.default or {})
    # (den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Den sourcing
    flake-file.inputs = {
      den.url = "github:denful/den/v0.18.0";
    };

    # Replacement for inporting den.flakeModules.strict not working
    den = {
      # Harden the schema
      schema = {
        host = den.lib.strict;
        user = den.lib.strict;
        home = den.lib.strict;
      };

      # Default batteries to use
      default = {
        includes = [
          den.batteries.define-user # Bootstrap OS level user accounts
          den.batteries.hostname # Seed hostname from hosts.<name>.hostname
          den.batteries.primary-user # Make user an admin on nixos, and primary-user on darwin
        ];
      };
    };
  };
}
