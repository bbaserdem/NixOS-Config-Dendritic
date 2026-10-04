# Secretspec global config for projects
{
  inputs,
  lib,
  den,
  ...
}: {
  # Aspect dispatch
  den = {
    schema.host = {
      includes = [
        den.aspects.development.policies.secretspec-config-dispatch
      ];
      imports = [
        {
          options = {
            development = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  secretspec = lib.mkOption {
                    description = "Secretspec setting enable";
                    default = {};
                    type = lib.types.submodule {
                      options = {
                        enable = lib.mkOption {
                          description = "Whether to enable secretspec on this host.";
                          default = false;
                          type = lib.types.bool;
                        };
                        isGlobal = lib.mkOption {
                          description = "Whether to install the package in user profile";
                          default = false;
                          type = lib.types.bool;
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        }
      ];
    };

    aspects.development = {
      # Dispatch policy
      policies.secretspec-config-dispatch = {host, ...}:
        lib.optionals
        (host.development.enable && host.development.secretspec.enable)
        [
          (den.lib.policy.include den.aspects.development._.secretspec)
        ];

      provides.secretspec = {
        name = "development/secretspec";
        provides.to-users = {
          user,
          host,
        }: {
          name = "development/secretspec(${user.userName}@${host.name})";
          homeManager = {pkgs, ...}: {
            imports = [
              inputs.self.modules.homeManager.secretspec-settings
            ];
            # Install the package to user env if wanted
            config = lib.mkIf host.development.secretspec.isGlobal {
              programs.secretspec.package = pkgs.secretspec;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.secretspec-settings = {lib, ...}: {
    key = "secretspec-settings#homeManager";
    # TODO; Secretspec module isn't present on 26.05; after migration remove this
    imports = [
      "${inputs.home-manager-unstable}/modules/programs/secretspec.nix"
    ];
    config = {
      programs.secretspec = {
        # We don't want global package available everywhere; just want global config
        enable = true;
        package = lib.mkDefault null;
        # Global config options
        settings = {
          providers = {
            local = "keyring://";
          };
        };
      };
    };
  };
}
