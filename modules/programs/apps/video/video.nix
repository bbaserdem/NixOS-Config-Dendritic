# Video related software suite
{inputs, ...}: {
  flake.modules.homeManager.video = {pkgs, ...}: {
    # Video related software suite

    # Video modules
    imports = with inputs.self.modules.homeManager; (
      [
        mpv
        yt-dlp
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
