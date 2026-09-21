# Office suite; use libreoffice
{...}: {
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
