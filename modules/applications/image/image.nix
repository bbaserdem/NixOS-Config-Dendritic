# Image related software suite
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.collections = {
      provides.image = {
        provides.to-users = {
          user,
          host,
        }: {
          name = "collections/image(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.image-applications
            ];
          };
        };
      };
    };
  };
  # Module for app dispatch
  flake.modules.homeManager.image-applications = {
    pkgs,
    lib,
    ...
  }: {
    key = "image-applications#homeManager";
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
      (
        # Linux only
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            digikam # Photos organizer
            kdePackages.gwenview # Photos viewer
          ];
        }
      )
    ];
  };
}
