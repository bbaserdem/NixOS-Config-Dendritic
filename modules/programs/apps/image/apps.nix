# Image related software suite
{...}: {
  flake.modules.homeManager.image = {
    pkgs,
    lib,
    ...
  }: {
    # Install these apps to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
          darktable # Raw file editor
          inkscape # Vector image editor
          imagemagick # Image editing library
          exiftool # Image info extractor
        ];
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          digikam # Photos organizer
        ];
      })
    ];
  };
}
