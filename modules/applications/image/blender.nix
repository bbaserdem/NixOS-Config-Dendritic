# Configuring blender
{inputs, ...}: {
  # Den aspect
  den = {
    aspects.applications = {
      provides.blender = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "applications/blender(${user.userName}@${host.name})";
          # Modules
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.blender-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.blender-settings
            ];
          };
          # Theming
          stylix = {
            targets.blender = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    darwin.blender-settings = {...}: {
      key = "blender-settings#darwin";
      # Broken on darwin nixpkgs, use homebrew
      config = {
        homebrew.casks = [
          "blender"
        ];
      };
    };
    homeManager.blender-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "blender-settings#homeManager";
      config = lib.mkMerge [
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            home.packages = with pkgs; [
              blender
            ];
          }
        )
      ];
    };
  };
}
