# Terminal emulators
{
  den,
  lib,
  ...
}: let
  configuredTerminals = [
    "kitty"
    "ghostty"
  ];
in {
  den = {
    # Schema for default pick
    schema = {
      host = {
        includes = [
          den.aspects.desktop.policies.terminal-host-dispatch
        ];
        options = {
          desktop = lib.mkOption {
            type = lib.types.submodule {
              options = {
                terminal = lib.mkOption {
                  description = "Terminal app to include in userspace, if any.";
                  default = null;
                  type = lib.types.nullOr (lib.types.enum configuredTerminals);
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          den.aspects.desktop.policies.terminal-user-dispatch
        ];
      };
    };

    aspects.desktop = {
      # Dispatch policies
      policies = {
        terminal-host-dispatch = {host, ...}:
          lib.optional
          (host.desktop.enable && (host.desktop.terminal != null))
          (den.lib.policy.include den.aspects.desktop._.${host.desktop.terminal});
        terminal-user-dispatch = {host, ...}:
          lib.optional
          (host.desktop.enable && (host.desktop.terminal != null))
          (den.lib.policy.include den.aspects.desktop._.${host.desktop.terminal}._.to-users);
      };
    };
  };
}
