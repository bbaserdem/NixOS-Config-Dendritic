# Serve documentation as a local website; from local packages
{
  den,
  lib,
  ...
}: {
  den = {
    schema.host = {
      includes = [
        den.aspects.system._.networking.policies.add-documentation
      ];
      options = {
        networking = lib.mkOption {
          type = lib.types.submodule {
            options = {
              local = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    docs = lib.mkOption {
                      description = "Whether to enable serving local documentation";
                      type = lib.types.bool;
                      default = true;
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    aspects.system = {
      provides.networking = {
        # Policy for dispatch
        policies.add-documentation = {host, ...}:
          lib.optional
          (host.networking.local.enable && host.networking.local.docs)
          (den.lib.policy.include den.aspects.system._.networking._.system-docs);
        # Aspect for providing the documentation static page
        provides.system-docs = {host}: {
          # Use the host variable to silece linter
          name = "system/networking/system-docs(@${host.name})";
          # Add to system packages to install, it even if localWeb.enable = false
          os = {pkgs, ...}: {
            environment.systemPackages = [pkgs.local.system-docs];
          };
          homeManager = {pkgs, ...}: {
            home.packages = [pkgs.local.system-docs];
          };
          # Emit to host quirk. {pkgs, ...}: is emitted as a function
          local-web = {
            service = "system-docs";
            # Emit from package
            root = {pkgs, ...}: "${pkgs.local.system-docs}";
          };
        };
      };
    };
  };
}
