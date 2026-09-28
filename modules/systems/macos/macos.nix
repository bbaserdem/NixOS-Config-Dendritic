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
        includes = [
          den.aspects.system._.macos._.system-info
        ];
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.macos-defaults
            # TODO: Migrate to a wolframite specific module
            inputs.self.modules.darwin.macos-behavior
          ];
        };
        # Defaults aspect
        provides.system-info = {host}: {
          name = "system/macos/system-info(@${host.name})";
          darwin = {lib, ...}: {
            config = lib.mkMerge [
              ( # Full computer name
                lib.mkIf (host.description != null) {
                  # Default state version for this nix-darwin version
                  networking.computerName = host.description;
                }
              )
              ( # Default state version for this nix-darwin version
                lib.mkIf (host.stateVersion != null) {
                  system.stateVersion = host.stateVersion;
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
    macos-defaults = {lib, ...}: {
      key = "macos-defaults#darwin";
      config = {
        # Default state version for this nix-darwin version
        system.stateVersion = lib.mkDefault 7;
      };
    };
    # TODO: These settings should be migrated to a wolframite specific module
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
            menuExtraClock = {
              Show24Hour = true;
            };
            screencapture = {
              # location = "";
              type = "png";
            };
          };
          keyboard = {
            enableKeyMapping = true;
          };
        };
      };
    };
  };
}
