# Enabling shared firefox module
{...}: {
  flake.modules = {
    # Home-manager configuration
    homeManager = {
      # Stylix theming for firefox
      stylix = {...}: {
        stylix.targets.firefox = {
          enable = true;
          colorTheme.enable = true;
          firefoxGnomeTheme.enable = true;
        };
      };

      # Firefox install
      firefox = {
        pkgs,
        lib,
        ...
      }: {
        # Use firefox-bin in the package
        config = lib.mkMerge [
          {
            programs.firefox.enable = true;
          }
          (
            # In Linux, prefer the nix-built package, and allow wrapping
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              programs.firefox.package = pkgs.firefox;
            }
          )
          (
            # In Darwin, use the binary provided by firefox; no wrapping
            # Also prefer the binary version to sidestep the app signing issue
            lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
              programs.firefox.package = null;
              home.packages = with pkgs; [
                firefox-bin
              ];
            }
          )
        ];
      };
    };
  };
}
