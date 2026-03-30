# Music related collector module
{self, ...}: {
  flake.modules.homeManager.audio = {pkgs, ...}: {
    # Music related software suite

    # We are a collection of various terminals; have them all available to the system
    imports = with self.modules.homeManager; (
      [
        mpd
        beets
        # streamrip
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isLinux
        then [
          midi
        ]
        else if pkgs.stdenv.hostPlatform.isDarwin
        then []
        else []
      )
    );
  };
}
