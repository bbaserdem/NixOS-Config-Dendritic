# MPV setup
{inputs, ...}: {
  # Setup for mpv aspect
  den = {
    aspects.applications = {
      provides.mpv = {
        provides.to-users = {
          host,
          user,
        }: {
          name = "applications/mpv(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.mpv-settings
              inputs.self.modules.homeManager.mpv-gui
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
  flake.modules.homeManager = {
    mpv-settings = {pkgs, ...}: {
      key = "mpv-settings#homeManager";
      config = {
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
      };
    };

    mpv-gui = {
      pkgs,
      lib,
      ...
    }: {
      key = "mpv-gui#homeManager";
      config = {
        home.packages = with pkgs; (
          []
          ++ (
            lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              haruna # KDE frontend for mpv
            ]
          )
          ++ (
            lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
              iina # MacOS frontend for mpv
            ]
          )
        );
      };
    };
  };
}
