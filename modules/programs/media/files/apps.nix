# Filesystem browsing programes
{...}: {
  flake.modules.homeManager.files = {pkgs, ...}: {
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
