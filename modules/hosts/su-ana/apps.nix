# Su-ana userspace configuration
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.darwin; [
      # Audio suite
      audio
      mpd
      # Browsers
      chrome
      chromium
      firefox
      # Comms
      comms
      # discord # broken
      # Documents suite
      docs
      obsidian
      office
      zathura
      # File browsing suite
      yazi
      # Image suite
      image
      blender
      # Video suite
      video
      # mpv # broken on darwin
      obs
      yt-dlp
      # Games
      gaming
    ];
  };
}
