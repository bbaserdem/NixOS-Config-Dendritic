# Image related software suite
{self, ...}: {
  flake.modules.home-manager.image = {pkgs, ...}: {
    # Image related software suite

    # Image modules
    imports = with self.modules.home-manager; (
      [
        blender
        gimp
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isLinux
        then [
        ]
        else if pkgs.stdenv.hostPlatform.isDarwin
        then []
        else []
      )
    );

    # Install these apps to userspace
    config = {
      home.packages = with pkgs; (
        [
          darktable # Raw file editor
          inkscape # Vector image editor
          digikam # Photos organizer
          imagemagick # Image editing library
          exiftool # Image info extractor
        ]
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux
          then [
          ]
          else if pkgs.stdenv.hostPlatform.isDarwin
          then []
          else []
        )
      );
    };
  };
}
