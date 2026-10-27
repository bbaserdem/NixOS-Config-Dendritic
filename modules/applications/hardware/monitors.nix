# Hardware; monitor information namespace
{
  den,
  lib,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    # Quirk for collecting the monitor info
    quirks.monitors.description = "Monitor records across fleet";

    # Host schema; register monitor info
    schema.host = {
      includes = [den.aspects.hardware.policies.monitor-quirk-pipe];
      # Monitor registry for hosts
      options.hardware = lib.mkOption {
        type = lib.types.submodule {
          options = {
            monitors = lib.mkOption {
              description = "Monitors on this PC";
              default = {};
              type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
                options = {
                  description = lib.mkOption {
                    description = "Monitor name, for querying";
                    default = name;
                    type = lib.types.str;
                  };
                  edid = lib.mkOption {
                    description = "EDID string of this monitor";
                    default = null;
                    type = lib.types.nullOr (
                      lib.types.strMatching
                      "^([a-fA-F0-9]{2}){128}$|^([a-fA-F0-9]{2}){256}$"
                    );
                  };
                  d = lib.mkOption {
                    description = "Preferred resolution of this monitor";
                    default = null;
                    type = lib.types.nullOr (lib.types.submodule {
                      options = {
                        h = lib.mkOption {
                          description = "Monitor height";
                          type = lib.types.int;
                        };
                        w = lib.mkOption {
                          description = "Monitor width";
                          type = lib.types.int;
                        };
                      };
                    });
                  };
                };
              }));
            };
          };
        };
      };
    };

    # Aspect; dispatch host info to quirk
    aspects.hardware = {
      # Fleet wide quirk sharing policy for monitors
      policies.monitor-quirk-pipe = {...}: [
        (
          den.lib.policy.pipe.from
          den.quirks.monitors
          [
            (
              den.lib.policy.pipe.collectAll
              ({host, ...}: host.hardware.monitors != {})
            )
          ]
        )
      ];
      monitors = {host, ...}:
        host.hardware.monitors
        |> lib.mapAttrsToList (
          id: monitor:
            monitor
            // {
              inherit id;
              parent = host.name;
            }
        );
    };
  };
}
