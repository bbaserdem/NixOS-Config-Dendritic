# Package overlays for flake
{inputs, ...}: {
  flake = {
    overlays = {
      # Our system overlays

      # Unstable overlay to pkgs
      unstable-packages = final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      };

      modifications = final: prev: {
        # Modifications to existing packages

        # Create yt-dlp aliases for overrides
        yt-dlp = prev.yt-dlp.override {withAlias = true;};

        # Make NNN use nerdfont symbols
        nnn = prev.nnn.override {withNerdIcons = true;};

        # Add features to ncmpcpp that are not compiled in in nixpkgs
        ncmpcpp = prev.ncmpcpp.override {
          outputsSupport = true;
          visualizerSupport = true;
          clockSupport = true;
          taglibSupport = true;
        };

        # Add turkish to libreoffice
        libreoffice = prev.libreoffice.override {
          variant = "fresh";
          langs = ["en-US" "tr"];
        };
      };
    };
  };
}
