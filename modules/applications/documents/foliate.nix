# Foliate, ebook reader
{inputs, ...}: {
  # Application setup with den
  den = {
    aspects.applications = {
      provides.foliate = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "applications/foliate(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.foliate-settings
            ];
          };
          stylix = {
            targets.foliate = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.foliate-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "foliate-settings#homeManager";
    config = lib.mkMerge [
      ( # Linux only
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          programs.foliate = {
            enable = true;
          };
        }
      )
    ];
  };
}
