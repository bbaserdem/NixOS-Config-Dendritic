# MPV setup
{inputs, ...}: {
  # Setup for mpv aspect
  den = {
    aspects.video = {
      provides.mpv = {
        name = "video/mpv";
        provides.to-users = {
          user,
          host,
        }: {
          name = "video/mpv(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.mpv-settings
            ];
          };
          stylix = {
            targets.mpv = {
              enable = true;
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules.homeManager.mpv-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "mpv-settings#homeManager";
    config = {
      # MPV module
      programs.mpv = {
        enable = true;
        package = pkgs.mpv;
        config = {
          keepaspect = true;
          autofit-larger = "90%x90%";
          scale = "ewa_lanczossharp";
          cscale = "ewa_lanczossharp";
          keep-open = true;
          video-sync = "display-resample";
          interpolation = true;
          tscale = "oversample";
        };
      };
      # Frontend
      home.packages = with pkgs; (
        []
        ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          haruna # KDE frontend for mpv
        ])
        ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
          iina # MacOS frontend for mpv
        ])
      );
    };
  };
}
