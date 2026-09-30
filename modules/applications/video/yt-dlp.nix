# YT-DLP downloader
{inputs, ...}: {
  # Aspect
  den = {
    aspects.video = {
      provides.yt-dlp = {
        name = "video/yt-dlp";
        provides.to-users = {
          user,
          host,
        }: {
          name = "video/yt-dlp(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.ytdlp-settings
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.ytdlp-settings = {
    pkgs,
    config,
    ...
  }: {
    key = "ytdlp-settings#homeManager";
    config = {
      programs.yt-dlp = {
        enable = true;
        package = pkgs.yt-dlp.override {withAlias = true;};
        settings = {
          # General options
          default-search = "youtube:1";
          live-from-start = true;
          color = "auto";
          # Video selection
          yes-playlist = true;
          # Download options
          concurrent-fragments = 5;
          # Filesystem options
          restrict-filenames = true;
          no-overwrites = true;
          write-description = true;
          write-info-json = true;
          clean-info-json = true;
          cache-dir = "${config.xdg.cacheHome}/yt-dlp";
          # Thumbnail options
          write-thumbnail = true;
          # Subtitle options
          write-subs = true;
          write-auto-subs = true;
          # Post processing
          audio-format = "best";
          audio-quality = 0;
          embed-subs = true;
          embed-thumbnail = true;
          embed-metadata = true;
          embed-chapters = true;
          # Sponsorblock
          sponsorblock-mark = "all";
        };
        extraConfig = ''
          --paths temp:/tmp/yt-dlp
        '';
      };
    };
  };
}
