# Configuring blender
{...}: {
  flake.modules.homeManager = {
    # Enable stylix theming with blender
    stylix = {...}: {
      stylix.targets.blender.enable = true;
    };

    # Install blender to userspace
    blender = {pkgs, ...}: {
      home.packages = with pkgs; [
        blender
      ];
    };
  };
}
