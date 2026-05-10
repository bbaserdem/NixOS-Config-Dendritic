# Flake parts init modules
{
  inputs,
  lib,
  ...
}: {
  # Collect factory modules
  flake.modules =
    lib.foldl lib.recursiveUpdate {
      # Local option for users to set their default shell
      homeManager.default = {lib, ...}: {
        options = {
          local.waylandShell = lib.mkOption {
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
    } [
      (inputs.self.factory.inclusionModules "noctalia")
      (inputs.self.factory.inclusionModules "hyprpanel")
    ];
}
