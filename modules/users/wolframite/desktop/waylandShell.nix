# Hyprpanel configuration
{...}: {
  flake.modules.homeManager.wolframite = {...}: {
    # Choose default shell for desktop environments
    local.waylandShell.default = "noctalia";
  };
}
