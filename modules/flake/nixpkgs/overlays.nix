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

        # Hunspell dictionaries, pre-configured
        # Provide this on system level so that it's available to all apps
        myHunspell = prev.hunspellWithDicts (with prev.hunspellDicts; [
          en_US
          tr_TR
        ]);
      };
    };
  };
}
