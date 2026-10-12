# Od-ata userspace applications
{den, ...}: {
  den = {
    aspects.od-ata = {
      includes = with den.aspects; [
        # Audio modules for tagging
        audio
        audio._.beets
        # Desktop modules
        desktop._.keepassxc
        # Documents
        documents
        documents._.zathura
        # Images
        image
        # Networking
        networking
        # Video
        video
        video._.transcoding
        video._.yt-dlp
      ];
    };
  };
}
