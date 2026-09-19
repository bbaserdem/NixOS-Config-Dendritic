# Mangohud; performance measurement
{inputs, ...}: {
  # Aspect for configuration
  den = {
    aspects.applications = {
      provides.mangohud = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/mangohud(${user.userName}@${host.name})";
          # Home manager module loading
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.mangohud-settings
            ];
          };
          # Stylix theming
          stylix = {
            targets.mangohud = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Settings module
  flake.modules.homeManager.mangohud-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "mangohud-settings#homeManager";
    config = lib.mkMerge [
      ( # Only available in linux
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.mangohud = {
            enable = true;
            enableSessionWide = false;
          };
        }
      )
    ];
  };
}
