# Hyprpanel configuration
{...}: {
  flake.modules.homeManager.wolframite = {
    lib,
    options,
    ...
  }: {
    # Choose default shell for desktop environments
    config = lib.optionalAttrs (lib.hasAttrByPath ["local" "waylandShell"] options) {
      local.waylandShell.default = "noctalia";
    };
  };
}
