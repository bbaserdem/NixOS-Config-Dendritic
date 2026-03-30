# Music related apps
{...}: {
  flake.modules.homeManager.audio = {pkgs, ...}: {
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
