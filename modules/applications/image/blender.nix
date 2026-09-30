# Configuring blender
{inputs, ...}: {
  # Den aspect
  den = {
    aspects.image = {
      provides.blender = {
        name = "image/blender";
        provides.to-users = {
          user,
          host,
        }: {
          name = "image/blender(${user.userName}@${host.name})";
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
      # Broken on darwin nixpkgs, use homebrew instead
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
      config = {
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            blender
          ])
        );
      };
    };
  };
}
