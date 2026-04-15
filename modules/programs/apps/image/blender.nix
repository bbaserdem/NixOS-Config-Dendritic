# Configuring blender
{...}: {
  flake.modules = {
    darwin.blender = {...}: {
      # Broken on darwin nixpkgs, use homebrew
      homebrew.casks = [
        "blender"
      ];
    };

    homeManager = {
      # Enable stylix theming with blender
      stylix = {...}: {
        stylix.targets.blender.enable = true;
      };

      # Install blender to userspace
      blender = {
        pkgs,
        lib,
        ...
      }: {
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
  };
}
