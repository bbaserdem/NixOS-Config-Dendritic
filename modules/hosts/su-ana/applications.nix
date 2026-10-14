# System applications for su-ana
{den, ...}: {
  den = {
    aspects.su-ana = {
      includes = with den.aspects; [
        # Audio applications
        audio
        audio._.mpd
        audio._.foobar
        # Desktop apps
        desktop._.keepassxc
        # Documents
        documents
        documents._.zotero
        documents._.obsidian
        documents._.libreoffice
        documents._.zathura
        # Images
        image
        # Networking
        networking
        networking._.discord
        networking._.slack
        networking._.zoom
        # Video
        video
        video._.mpv
        video._.obs
      ];
    };
  };
}
