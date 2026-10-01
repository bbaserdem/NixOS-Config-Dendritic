# Speech to text solutions
# TODO: Do macos local stt as well
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    schema = {
      host = {
        includes = [
          den.aspects.desktop.policies.stt-host-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              desktop = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    stt = lib.mkOption {
                      description = "Settings for STT transcription";
                      default = {};
                      type = lib.types.submodule {
                        options = {
                          enable = lib.mkOption {
                            description = "Enable STT tooling for this host.";
                            default = false;
                            type = lib.types.bool;
                          };
                          backend = lib.mkOption {
                            description = "Which STT tooling to use";
                            default =
                              if config.class == "darwin"
                              then null
                              else "voxtype";
                            type = lib.types.nullOr (lib.types.enum [
                              "voxtype"
                            ]);
                          };
                          # TODO: add ways to configure stt backends with host hardware
                        };
                      };
                    };
                  };
                };
              };
            };
          })
        ];
      };

      # User; OSD settings
      user = {
        includes = [
          den.aspects.desktop.policies.stt-user-dispatch
        ];
        options = {
          stt = lib.mkOption {
            description = "Settings for STT transcription";
            default = {};
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  description = "Enable STT tooling for this user";
                  default = false;
                  type = lib.types.bool;
                };
                osd = lib.mkOption {
                  description = "On-screen display settings, if available.";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Enable OSD for stt.";
                        default = false;
                        type = lib.types.bool;
                      };
                      frontend = lib.mkOption {
                        description = "OSD frontend to use";
                        default = "native";
                        type = lib.types.str;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    # Aspect
    aspects.desktop = {
      # Policies
      policies = {
        stt-host-dispatch = {host, ...}:
          lib.optionals
          (host.desktop.enable && host.desktop.stt.enable)
          (
            [
              (den.lib.policy.include den.aspects.desktop._.stt)
            ]
            ++ (
              lib.optional (host.desktop.stt.backend != null)
              (
                den.lib.policy.include
                den.aspects.desktop._.stt._.${host.desktop.stt.backend}
              )
            )
          );
        stt-user-dispatch = {
          host,
          user,
          ...
        }:
          lib.optionals
          (host.desktop.enable && host.desktop.stt.enable && user.stt.enable)
          (
            [
              (den.lib.policy.include den.aspects.desktop._.stt._.user-setup)
            ]
            ++ (
              lib.optional (host.desktop.stt.backend != null) (
                den.lib.policy.include
                den.aspects.desktop._.stt._.${host.desktop.stt.backend}._.user-setup
              )
            )
          );
      };

      # Aspect; stub for now
      provides.stt = {
        name = "desktop/stt";
        provides.user-setup = {
          user,
          host,
        }: {
          name = "desktop/stt(${user.userName}@${host.name})";
        };
      };
    };
  };
}
