# Flake parts for wayland shells
{...}: {
  # Collect factory modules
  flake.modules.homeManager.waylandShell = {lib, ...}: {
    options = {
      local.waylandShell = {
        default = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum [
            "noctalia"
            "hyprpanel"
          ]);
          default = null;
          description = ''
            Default shell to be used by wayland window managers
          '';
        };
      };
    };
  };
}
