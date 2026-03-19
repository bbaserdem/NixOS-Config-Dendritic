# Filesystem browsing utilities
{self, ...}: {
  flake.modules.home-manager.files = {pkgs, ...}: {
    # File browsing software

    # Modules
    imports = with self.modules.home-manager; (
      [
        yazi
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
        ]
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux
          then [
            baobab # Disk usage analyzer
            kdePackages.dolphin # File browser
          ]
          else if pkgs.stdenv.hostPlatform.isDarwin
          then []
          else []
        )
      );
    };
  };
}
