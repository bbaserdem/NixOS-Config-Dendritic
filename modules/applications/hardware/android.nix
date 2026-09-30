# Configuring ADB
{
  inputs,
  den,
  lib,
  ...
}: {
  # Configuration aspect for this hardware
  den = {
    # Host config option
    schema = {
      host = {
        includes = [
          den.aspects.hardware._.android.policies.android-host-dispatch
        ];
        options = {
          hardware = lib.mkOption {
            type = lib.types.submodule {
              options = {
                android = lib.mkOption {
                  description = "Android access tools";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Whether to enable ADB tooling";
                        default = false;
                        type = lib.types.bool;
                      };
                      droidcam = lib.mkOption {
                        description = "Whether to enable droidcam (phone as webcam)";
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
      };
      user = {
        includes = [
          den.aspects.hardware._.android.policies.android-user-dispatch
        ];
      };
    };

    aspects.hardware = {
      provides.android = {
        name = "hardware/android";
        # Dispatch policy
        policies = {
          android-host-dispatch = {host, ...}:
            (
              lib.optional
              host.hardware.android.enable
              (den.lib.policy.include den.aspects.hardware._.android)
            )
            ++ (
              lib.optional
              host.hardware.android.droidcam
              (den.lib.policy.include den.aspects.hardware._.android._.droidcam)
            );
          android-user-dispatch = {host, ...}: (
            lib.optional
            host.hardware.android.enable
            (den.lib.policy.include den.aspects.hardware._.android._.to-users)
          );
        };

        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.android-adb
          ];
        };
        # Home-manager configuration
        provides.to-users = {
          user,
          host,
        }: {
          name = "hardware/android(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.android-adb
            ];
          };
        };
        # Droidcam enable
        provides.droidcam = {
          name = "hardware/android/droidcam";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.android-droidcam
            ];
          };
          # Emit port quirk for opening access for droidcam
          local-ports = [
            {
              port = 4747;
              proto = "all";
            }
          ];
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Nixos module (only nixos available for now)
    nixos.android-droidcam = {pkgs, ...}: {
      key = "android-droidcam#nixos";
      config = {
        programs.droidcam.enable = true;
        environment.systemPackages = with pkgs; [
          v4l-utils
        ];
      };
    };
    nixos.android-adb = {pkgs, ...}: {
      key = "android-adb#nixos";
      config = {
        environment.systemPackages = with pkgs; [
          android-tools
        ];
      };
    };
    # Home manager; install go-mtpfs
    homeManager.android-adb = {pkgs, ...}: {
      key = "android-adb#homeManager";
      config = {
        home.packages = with pkgs; (
          [
          ]
          ++ ( # go-mtpfs, and mtpfs is broken on darwin
            lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              go-mtpfs
              mtpfs
            ]
          )
        );
      };
    };
  };
}
