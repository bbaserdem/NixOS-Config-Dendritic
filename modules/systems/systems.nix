# General systems boilerplate for den
{
  den,
  lib,
  ...
}: {
  den = {
    schema.host = {
      includes = [
        # Always include the base system in every host scope
        den.aspects.system
      ];
      imports = [
        {
          # System state version module
          options = {
            stateVersion = lib.mkOption {
              description = "Host specific stateVersion string";
              type = lib.types.nullOr (lib.types.oneOf [
                lib.types.str
                lib.types.int
              ]);
              default = null;
            };
          };
        }
      ];
    };

    # System aspect; generic module dispatching to appropriate outputs
    aspects.system = {
      # Auto-include our dispatch policy
      includes = [
        den.aspects.system._.platform-dispatch
      ];

      # Needs to happen with aspect; since policies don't fire recursively
      provides.platform-dispatch = {host}: {
        name = "system/platform-dispatch";
        includes =
          (
            # Set up NixOS base config
            lib.optional
            (host.class == "nixos")
            den.aspects.system._.nixos
          )
          ++ (
            # Set up MacOS base config
            lib.optional
            (host.class == "darwin")
            den.aspects.system._.macos
          );
      };
    };
  };
}
