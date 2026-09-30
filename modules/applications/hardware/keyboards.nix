# Managing keyboard firmware access
{
  inputs,
  den,
  lib,
  ...
}: {
  # Aspect and dispatch
  den = {
    # Host config option
    schema.host = {
      includes = [
        den.aspects.hardware._.keyboards.policies.keyboards-dispatch
      ];
      options = {
        hardware = lib.mkOption {
          type = lib.types.submodule {
            options = {
              keyboards = lib.mkOption {
                description = "Keyboard management metadata";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Enable keyboard related management";
                      default = true;
                      type = lib.types.bool;
                    };
                    qmk = lib.mkOption {
                      description = "Whether to enable QMK.";
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

    aspects.hardware = {
      provides.keyboards = {
        name = "hardware/keyboards";
        # Dispatch policy
        policies.keyboards-dispatch = {host, ...}:
          lib.optionals
          host.hardware.keyboards.enable
          (
            [
              (den.lib.policy.include den.aspects.hardware._.keyboards)
            ]
            ++ (
              lib.optional host.hardware.keyboards.qmk
              (den.lib.policy.include den.aspects.hardware._.keyboards._.qmk)
            )
          );

        # QMK
        provides.qmk = {
          name = "hardware/keyboards/qmk";
          # Module
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.qmk-settings
            ];
          };
          # QMK userspace tooling install to all users
          provides.to-users = {
            user,
            host,
          }: {
            name = "hardware/keyboards/qmk(${user.userName}@${host.name})";
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.qmk-settings
              ];
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules = {
    nixos.qmk-settings = {...}: {
      key = "qmk-settings#nixos";
      config = {
        hardware.keyboard.qmk = {
          enable = true;
          keychronSupport = true;
        };
      };
    };
    homeManager.qmk-settings = {pkgs, ...}: {
      key = "qmk-settings#homeManager";
      config = {
        home.packages = with pkgs; [
          qmk
          qmk_hid
          keymapviz
        ];
      };
    };
  };
}
