# Hardware; monitor information namespace
{lib, ...}: {
  # Dispatch modules in aspect
  den = {
    schema.host.options.hardware = lib.mkOption {
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
}
