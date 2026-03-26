# Enabling terminals in the user-space
{inputs, ...}: {
  flake.modules.home-manager.terminal = {...}: {
    # We are a collection of various terminals; have them all available to the system
    imports = with inputs.self.modules.home-manager; [
      kitty
      ghostty
    ];
  };
}
