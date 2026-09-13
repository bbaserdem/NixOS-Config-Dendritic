# Configuring MPD gui clients
{...}: {
  # Cantata as gui in linux
  flake.modules.homeManager.mpd-gui = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      home.packages = with pkgs; [
        cantata
      ];
    };
  };

  # SWMPC as gui in darwin
  flake.modules.darwin.mpd-gui = {...}: {
    homebrew.masApps."swmpc" = 6743818735;
  };
}
