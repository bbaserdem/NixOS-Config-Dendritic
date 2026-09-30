# Video applications
{inputs, ...}: {
  # Dispatch modules in aspect
  den = {
    aspects.video = {
      # Base aspect
      name = "video";
      provides.to-users = {
        user,
        host,
      }: {
        name = "video(${user.userName}@${host.name})";
        # By default, just provide VLC to ensure we can always play videos
        homeManager = {...}: {
          imports = [
            inputs.self.modules.homeManager.vlc
          ];
        };
      };
      # Standalone apps
      provides.editing = {
        name = "video/editing";
        provides.to-users = {
          user,
          host,
        }: {
          name = "video/editing(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.video-editing
            ];
          };
        };
      };
      provides.transcoding = {
        name = "video/transcoding";
        provides.to-users = {
          user,
          host,
        }: {
          name = "video/transcoding(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.video-transcoding
            ];
          };
        };
      };
    };
  };

  # General applications to deal with video
  flake.modules.homeManager = {
    # Standalone apps
    vlc = {
      pkgs,
      lib,
      ...
    }: {
      key = "vlc#homeManager";
      config = {
        # Both platforms
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            vlc # Easy playback alternative to keep on hand besides mpv
          ])
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            vlc-bin # VLC linux only; need the binary
          ])
        );
      };
    };
    video-transcoding = {
      pkgs,
      lib,
      ...
    }: {
      key = "video-transcoding#homeManager";
      config = {
        # Both platforms
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            handbrake # Video conversion/re-encoding (broken on darwin)
          ])
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            shotcut # Handbrake alternative in macos
          ])
        );
      };
    };
    video-editing = {
      pkgs,
      lib,
      ...
    }: {
      key = "video-editing#homeManager";
      config = {
        # Both platforms
        home.packages = with pkgs; (
          []
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            kdePackages.kdenlive # Video editing software
          ])
          ++ (lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            # TODO; No kdenlive alternative picked yet in darwin
          ])
        );
      };
    };
  };
}
