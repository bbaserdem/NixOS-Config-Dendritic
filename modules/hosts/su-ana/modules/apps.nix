# Su-ana applications
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # Darwin modules to import
    imports = with inputs.self.modules.darwin; [
      # Music
      audio
      mpd
      # Browsers
      chrome
      chromium
      firefox
      # Messaging
      comms
      discord
      # Documents
      docs
      obsidian
      zathura
      # Files
      files
      yazi
      # Image
      image
      blender
      # Video
      video
      mpv
      obs
      yt-dlp
      # Gaming
      gaming
    ];
  };
}
