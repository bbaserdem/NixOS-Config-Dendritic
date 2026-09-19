# Video applications
{
  inputs,
  den,
  ...
}: {
  # Dispatch modules in aspect
  den = {
    aspects.collections = {
      provides.video = {
        # Include mpv aspect here
        includes = [
          den.aspects.applications._.mpv
        ];
        provides.to-users = {
          user,
          host,
        }: {
          name = "collections/video(${user.userName}@${host.name})";
          # Provide darwin-only modules
          darwin = {...}: {
            imports = with inputs.self.modules.darwin; [
              # OBS
              obs-settings
            ];
          };
          # Provide nixos modules
          nixos = {...}: {
            imports = with inputs.self.modules.nixos; [
              # OBS
              obs-settings
            ];
          };
          # Home manager collection
          homeManager = {...}: {
            imports = with inputs.self.modules.homeManager; [
              # General apps
              video-applications
              # YT-DLP
              ytdlp-settings
            ];
          };
        };
      };
    };
  };

  # General applications to deal with video
  flake.modules.homeManager.video-applications = {
    pkgs,
    lib,
    ...
  }: {
    key = "video-applications#homeManager";
    config = {
      # Both platforms
      home.packages = with pkgs; (
        [
          # No shared packages as of yet.
        ]
        ++ ( # Linux only packages
          lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            vlc # Easy playback alternative to keep on hand besides mpv
            kdePackages.kdenlive # Video editing software
            handbrake # Video conversion/re-encoding (broken on darwin)
          ]
        )
        ++ ( # Darwin only packages
          lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            vlc-bin # VLC linux only; need the binary
            shotcut # Handbrake alternative in macos
          ]
        )
      );
    };
  };
}
