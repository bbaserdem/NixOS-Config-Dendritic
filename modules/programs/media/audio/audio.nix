# Music related software suite
{self, ...}: {
  flake.modules.home-manager.audio = {pkgs, ...}: {
    # Music related software suite

    # We are a collection of various terminals; have them all available to the system
    imports = with self.modules.home-manager; (
      [
        mpd
        ncmpcpp
        beets
        # streamrip
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isLinux
        then [
          listenbrainz
          midi
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
          streamrip # Music downloader
          audacity # Audio editor
          musescore # Score editing
          picard # Tag music
          chromaprint # Calculate acoustic id
        ]
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux
          then [
            cantata
            prejectm-sdl-cpp # Broken on darwin
          ]
          else if pkgs.stdenv.hostPlatform.isDarwin
          then []
          else []
        )
      );
    };
  };
}
