# Image related software
{inputs, ...}: {
  den = {
    aspects.image = {
      name = "image";
      provides.to-users = {
        user,
        host,
      }: {
        name = "image(${user.userName}@${host.name})";
        homeManager = {...}: {
          imports = [
            inputs.self.modules.homeManager.image-utilities
          ];
        };
      };
      # Standalone aspects
      provides.darktable = {
        name = "image/darktable";
        provides.to-users = {
          user,
          host,
        }: {
          name = "image/darktable(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.darktable
            ];
          };
        };
      };
      provides.inkscape = {
        name = "image/inkscape";
        provides.to-users = {
          user,
          host,
        }: {
          name = "image/inkscape(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.inkscape
            ];
          };
        };
      };
      provides.digikam = {
        name = "image/digikam";
        provides.to-users = {
          user,
          host,
        }: {
          name = "image/digikam(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.digikam
            ];
          };
        };
      };
      provides.gwenview = {
        name = "image/gwenview";
        provides.to-users = {
          user,
          host,
        }: {
          name = "image/gwenview(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.gwenview
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager = {
    image-utilities = {
      pkgs,
      lib,
      ...
    }: {
      key = "image-utilities#homeManager";
      # Install these apps to userspace
      config = {
        home.packages = with pkgs; (
          [
            imagemagick # Image editing library
            exiftool # Image info extractor
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            exiftool
          ])
        );
      };
    };
    # Standalone apps
    darktable = {pkgs, ...}: {
      key = "darktable#homeManager";
      config = {
        home.packages = with pkgs; [
          darktable
        ];
      };
    };
    inkscape = {pkgs, ...}: {
      key = "inkscape#homeManager";
      config = {
        home.packages = with pkgs; [
          inkscape
        ];
      };
    };
    digikam = {
      pkgs,
      lib,
      ...
    }: {
      key = "digikam#homeManager";
      config = {
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            digikam
          ])
        );
      };
    };
    gwenview = {
      pkgs,
      lib,
      ...
    }: {
      key = "gwenview#homeManager";
      config = {
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            gwenview
          ])
        );
      };
    };
  };
}
