# Enabling terminals in the user-space
{self, ...}: {
  flake.modules.home-manager.terminal = {...}: {
    # We are a collection of various terminals; have them all available to the system
    imports = [
      self.modules.home-manager.kitty
    ];
  };
}
