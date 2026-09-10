# Firefox setting module
{inputs, ...}: {
  # Hook up firefox to den
  den = {
    aspects.applications = {
      provides.firefox = {
        # Just dispatch aspect to the user scope
        provides.to-users = {
          host,
          user,
        }: {
          # Collission protection
          name = "applications/firefox(${user.userName}@${host.name})";
          # Dispatch the home manager modules
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.firefox-settings
              inputs.self.modules.homeManager.firefox-profiles
            ];
          };
          # Establish theming
          stylix = {lib, ...}: {
            targets.firefox = {
              # Can only enable when profiles are non-empty
              enable = lib.mkOptionDefault false;
              colorTheme.enable = true;
              firefoxGnomeTheme.enable = true;
            };
          };
        };
      };
    };
  };

  # Firefox setting module
  flake.modules.homeManager.firefox-settings = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.firefox.enable = true;
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.firefox.package = pkgs.firefox;
        }
      )
      (
        # Sometimes the nixpkgs version is broken on darwin
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.firefox.package = pkgs.firefox;
        }
      )
    ];
  };
}
