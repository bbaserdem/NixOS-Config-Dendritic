# Filesystem browsing utilities
{inputs, ...}: {
  flake.modules.homeManager.files = {pkgs, ...}: {
    # File browsing software

    # Modules
    imports = with inputs.self.modules.home-manager; (
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
  };
}
