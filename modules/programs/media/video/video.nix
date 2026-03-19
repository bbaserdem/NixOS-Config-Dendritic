# Video related software suite
{self, ...}: {
  flake.modules.home-manager.video = {pkgs, ...}: {
    # Video related software suite

    # Video modules
    imports = with self.modules.home-manager; (
      [
        mpv
        yt-dlp
        # obs
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
          vlc # Playback alternative to mpd
          haruna # Frontend for mpv
        ]
        ++ (
          if pkgs.stdenv.hostPlatform.isLinux
          then [
            handbrake # Video conversion tool (broken on darwin; deps)
            kdePackages.kdenlive # Video editing software suite
          ]
          else if pkgs.stdenv.hostPlatform.isDarwin
          then []
          else []
        )
      );
    };
  };
}
