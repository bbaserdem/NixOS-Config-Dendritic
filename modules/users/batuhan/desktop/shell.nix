# Hyprpanel configuration
{...}: {
  flake.modules.homeManager.batuhan = {...}: {
    # Choose default shell for desktop environments
    local.waylandShell = "noctalia";
  };
}
