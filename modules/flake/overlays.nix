# Package overlays
{...}: {
  flake = {
    overlays = {
      # Our system overlays

      modifications = final: prev: {
        # Modifications to existing packages
      };
    };
  };
}
