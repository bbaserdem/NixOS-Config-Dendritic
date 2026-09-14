# Configuring MPD gui clients
{...}: {
  # Cantata as gui in linux
  flake.modules.homeManager.mpd-gui = {
    pkgs,
    lib,
    ...
  }: {
    key = "mpd-gui#homeManager";
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      home.packages = with pkgs; [
        cantata
      ];
    };
  };

  # SWMPC as gui in darwin
  flake.modules.darwin.mpd-gui = {...}: {
    key = "mpd-gui#darwin";
    config = {
      homebrew.masApps."swmpc" = 6743818735;
    };
  };
}
