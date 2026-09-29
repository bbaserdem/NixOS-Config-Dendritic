# Direnv setup
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    schema.host = {
      includes = [
        den.aspects.development.policies.direnv-host-dispatch
      ];
      imports = [
        {
          options = {
            development = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  direnv = lib.mkOption {
                    description = "Direnv settings";
                    default = {};
                    type = lib.types.submodule {
                      options = {
                        enable = lib.mkOption {
                          description = "Whether to enable direnv on this host.";
                          default = true;
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

    # Aspect
    aspects.development = {
      # Policy dispatch
      policies.direnv-host-dispatch = {host, ...}:
        lib.optionals
        host.development.direnv.enable
        [
          (den.lib.policy.include den.aspects.development._.direnv)
        ];
      provides.direnv = {
        name = "development/direnv";
        provides.to-users = {
          user,
          host,
        }: {
          name = "development/direnv(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.development-direnv
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.development-direnv = {
    pkgs,
    lib,
    ...
  }: {
    key = "development-direnv#homeManager";
    config = lib.mkMerge [
      {
        # Enable direnv for our shells
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
          config = {
            global = {
              load_dotenv = false;
              warn_timeout = "0";
            };
          };
        };

        # Reformat direnv output to be muted
        home.sessionVariables = let
          logFormat = "\"$(printf '\\033[2;1;3mdirenv:\\033[22;23m %%s\\033[0m')\"";
        in {
          "DIRENV_LOG_FORMAT" = logFormat;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          # TODO: Check this if this still holds
          # On nixpkgs-25.11 darwin of direnv is broken, pull from unstable
          programs.direnv.package = pkgs.unstable.direnv;
        }
      )
    ];
  };
}
