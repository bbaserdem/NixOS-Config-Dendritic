# Configuring OS defaults for macos systems
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.system = {
      provides.macos = {
        name = "system/macos";
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.macos-defaults
            inputs.self.modules.darwin.macos-behavior
          ];
        };
        # Defaults aspect
        includes = [
          den.aspects.system._.macos._.system-info
        ];
        provides.system-info = {host}: {
          name = "system/macos/system-info(@${host.name})";
          darwin = {lib, ...}: {
            config = lib.mkMerge [
              ( # Primary user setting in macos (will be deprecated)
                lib.mkIf (host.primaryUser != null) {
                  system = {inherit (host) primaryUser;};
                }
              )
              ( # Pretty name for this computer
                lib.mkIf (host.description != null) {
                  networking.computerName = host.description;
                }
              )
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.darwin = {
    macos-defaults = {
      lib,
      options,
      ...
    }: {
      key = "macos-defaults#darwin";
      config = lib.mkMerge [
        {
          # Default state version for this nix-darwin version
          system.stateVersion = lib.mkOverride 110 7;
        }
        ( # Establish the defaults for managed home-manager invocations
          lib.mkIf (options ? home-manager) {
            home-manager.sharedModules = [
              inputs.self.modules.homeManager.hm-defaults
            ];
          }
        )
      ];
    };
    # These are sane default settings
    macos-behavior = {...}: {
      key = "macos-behavior#darwin";
      config = {
        system = {
          # Don't need this with flakes
          checks.verifyNixPath = false;
          defaults = {
            LaunchServices = {
              LSQuarantine = false;
            };
            NSGlobalDomain = {
              AppleShowAllExtensions = true;
              ApplePressAndHoldEnabled = false;
              # 120, 90, 60, 30, 12, 6, 2
              KeyRepeat = 2;
              # 120, 94, 68, 35, 25, 15
              InitialKeyRepeat = 15;
            };
            finder = {
              _FXShowPosixPathInTitle = true;
            };
            loginwindow = {
              DisableConsoleAccess = false;
              GuestEnabled = false;
            };
          };
        };
      };
    };
  };
}
