# Desktop setup
{
  inputs,
  den,
  lib,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    # Host schema settings regarding enabled desktops
    schema.host = {
      includes = [
        den.aspects.desktop.policies.desktop-dispatch
      ];
      options = {
        desktop = lib.mkOption {
          description = "Desktop related metadata";
          default = {};
          type = lib.types.submodule {
            options = {
              enable = lib.mkOption {
                description = "Whether to enable desktop modules for this host.";
                default = true;
                type = lib.types.bool;
              };
              defaultSession = lib.mkOption {
                description = "Default desktop session.";
                default = null;
                type = lib.types.nullOr (lib.types.enum [
                  "gnome"
                  "plasma"
                  "hyprland"
                ]);
              };
            };
          };
        };
      };
    };

    aspects.desktop = {
      # Base aspect
      name = "desktop";
      includes = [
        den.aspects.desktop._.defaults
      ];
      # Policy for adding base aspect to user scope
      policies.desktop-dispatch = {host, ...}:
        lib.optionals
        host.desktop.enable
        (
          [
            (den.lib.policy.include den.aspects.desktop)
          ]
          # Default session additions
          ++ (
            lib.optional
            (host.desktop.defaultSession == "gnome")
            (den.lib.policy.include den.aspects.desktop._.gnome)
          )
          ++ (
            lib.optional
            (host.desktop.defaultSession == "plasma")
            (den.lib.policy.include den.aspects.desktop._.plasma)
          )
        );

      provides.defaults = {host}: {
        name = "desktop/defaults(@${host.name})";
        # In nixos; declare the defaultSession
        nixos = {...}: {
          config = lib.mkIf (host.desktop.defaultSession != null) {
            services.displayManager.defaultSession =
              # Custom parsing
              if host.desktop.defaultSession == "hyprland"
              then "hyprland-uwsm"
              else host.desktop.defaultSession;
          };
        };
      };
    };
  };
}
