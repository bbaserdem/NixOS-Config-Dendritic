# Image related software suite
{...}: {
  flake.modules.homeManager.image = {pkgs, ...}: {
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
