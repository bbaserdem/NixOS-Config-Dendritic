# Yubikey setup
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Host config option
    schema = {
      host = {
        includes = [
          den.aspects.hardware._.yubikey.policies.yubikey-host-dispatch
        ];
        options = {
          hardware = lib.mkOption {
            type = lib.types.submodule {
              options = {
                yubikey = lib.mkOption {
                  description = "YubiKey interaction";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Enable yubikey on this host";
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
      };
      user = {
        includes = [
          den.aspects.hardware._.yubikey.policies.yubikey-user-dispatch
        ];
      };
    };

    aspects.hardware = {
      provides.yubikey = {
        name = "hardware/yubikey";
        # Dispatch policy
        policies = {
          yubikey-host-dispatch = {host, ...}:
            lib.optionals
            host.hardware.yubikey.enable
            (den.lib.policy.include den.aspects.hardware._.yubikey);
          yubikey-user-dispatch = {host, ...}:
            lib.optionals
            host.hardware.yubikey.enable
            (den.lib.policy.include den.aspects.hardware._.yubikey._.to-users);
        };

        # Modules
        os = {...}: {
          imports = [
            inputs.self.modules.generic.yubikey-settings
          ];
        };
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.yubikey-settings
          ];
        };
        # Override to defaults for user settings
        provides.to-users = {
          user,
          host,
        }: {
          name = "hardware/yubikey(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.yubikey-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Generic module for both nixos and darwin
    generic.yubikey-settings = {pkgs, ...}: {
      key = "yubikey-settings#generic";
      config = {
        # Install packages to userspace
        environment.systemPackages = with pkgs; [
          yubikey-manager
        ];
      };
    };

    # NixOS Yubikey integration
    nixos.yubikey-settings = {pkgs, ...}: {
      key = "yubikey-settings#nixos";
      config = {
        services = {
          # Enable smartcard daemon
          pcscd.enable = true;
          # Udev rules for non-root access
          udev.packages = with pkgs; [
            yubikey-personalization
          ];
        };
        # Enable yubikey hardware
        hardware.gpgSmartcards.enable = true;
      };
    };

    # Home manager
    homeManager.yubikey-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "yubikey-settings#homeManager";
      config = lib.mkMerge [
        (
          # In linux, internal ccid conflicts with pcscd; (auto in darwin)
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            programs.gpg.scdaemonSettings.disable-ccid = true;
          }
        )
      ];
    };
  };
}
