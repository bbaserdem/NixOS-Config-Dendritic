# Video related software suite
{...}: {
  flake.modules.homeManager.video = {
    pkgs,
    lib,
    ...
  }: {
    # Install these apps to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
        ];
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          vlc # Playback alternative to mpd
          haruna # Frontend for mpv
          kdePackages.kdenlive # Video editing software suite
          handbrake # Video conversion tool (broken on darwin; deps)
        ];
      })
      (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
        home.packages = with pkgs; [
          vlc-bin # Playback alternative to mpd
        ];
      })
    ];
  };
}
