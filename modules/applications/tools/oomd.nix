# OOMD: Systemd OOM watchdog for linux
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
          den.aspects.tools.policies.oomd-host-dispatch
        ];
        options = {
          tools = lib.mkOption {
            type = lib.types.submodule {
              options = {
                oomd = lib.mkOption {
                  description = "Enable OOMD management";
                  default = true;
                  type = lib.types.bool;
                };
              };
            };
          };
        };
      };
    };

    aspects.tools = {
      # Ship policies
      policies.oomd-host-dispatch = {host, ...}:
        lib.optionals
        (host.tools.enable || host.tools.oomd)
        [
          (den.lib.policy.include den.aspects.tools._.oomd)
        ];

      provides.oomd = {
        name = "tools/oomd";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.oomd
          ];
        };
      };
    };
  };

  # Modules
  flake.modules.nixos.oomd = {...}: {
    key = "oomd#nixos";
    config = {
      systemd.oomd = {
        enable = true;
        enableUserSlices = true;
        # enableRootSlice = true;
        # enableSystemSlice = true;
      };
    };
  };
}
