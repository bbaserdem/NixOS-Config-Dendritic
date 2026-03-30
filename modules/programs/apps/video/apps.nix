# Video related software suite
{...}: {
  flake.modules.homeManager.video = {pkgs, ...}: {
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
