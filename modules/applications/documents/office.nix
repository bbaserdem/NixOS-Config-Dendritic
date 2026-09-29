# Office suite; with libreoffice
{inputs, ...}: {
  # Aspect
  den = {
    aspects.documents = {
      provides.libreoffice = {
        name = "documents/libreoffice";
        provides.to-users = {
          user,
          host,
        }: {
          name = "documents/libreoffice(${user.userName}@${host.name})";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.libreoffice-settings
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.libreoffice-settings
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Install from brew in darwin
    darwin.libreoffice-settings = {...}: {
      key = "libreoffice-settings#darwin";
      config = {
        homebrew.casks = [
          "libreoffice"
          "libreoffice-language-pack"
        ];
      };
    };

    # For linux, install to userspace
    homeManager.libreoffice-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "libreoffice-settings#homeManager";
      config = {
        home.packages = with pkgs; (
          [
          ]
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            libreoffice-qt-fresh
          ])
        );
      };
    };
  };
}
