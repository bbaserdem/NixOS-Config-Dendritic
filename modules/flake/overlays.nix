# Package overlays
{...}: {
  flake = {
    overlays = {
      # Our system overlays

      modifications = final: prev: {
        # Modifications to existing packages
        python3Packages = prev.python3Packages.overrideScope (pyfinal: pyprev: {
          ffmpeg-python = pyprev.ffmpeg-python.overrideAttrs {
            doCheck = false;
          };
        });
      };
    };
  };
}
