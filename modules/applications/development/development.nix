# Development tools setup
{
  den,
  lib,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    # Host schema settings regarding enabled desktops
    schema.host = {
      includes = [
        den.aspects.development.policies.development-dispatch
      ];
      options = {
        development = lib.mkOption {
          description = "Develoment related feature set";
          default = {};
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                description = "Whether to enable development environment for this host.";
                default = true;
                type = lib.types.bool;
              };
            };
          };
        };
      };
    };

    aspects.development = {
      # Base aspect
      name = "development";
      includes = [
        den.aspects.development._.defaults
      ];
      # Policy for adding base aspect to user scope
      policies.development-dispatch = {host, ...}:
        lib.optionals
        host.development.enable
        [
          (den.lib.policy.include den.aspects.development)
        ];
      # Default dev settings
      provides.defaults = {host}: {
        name = "development/defaults(@${host.name})";
      };
    };
  };
}
