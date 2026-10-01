# System applications for yertengri, available on all users
{den, ...}: {
  den = {
    aspects.yertengri = {
      includes = with den.aspects; [
        # Audio applications
        audio
        audio._.tenacity
        audio._.musescore
        audio._.beets
        audio._.fluidsynth
        audio._.mpd
        # Desktop apps
        desktop._.keepassxc
        desktop._.kdeconnect
        # Documents
        documents
        documents._.calibre
        documents._.okular
        documents._.zotero
        documents._.foliate
        documents._.newsboat
        documents._.obsidian
        documents._.libreoffice
        documents._.zathura
        # Images
        image
        image._.darktable
        image._.inkscape
        image._.digikam
        image._.gwenview
        image._.blender
        image._.gimp
        # Networking
        networking
        networking._.chromium
        networking._.discord
        networking._.firefox
        networking._.librewolf
        networking._.remmina
        networking._.signal
        networking._.slack
        networking._.zoom
        networking._.ferdium
        # Video
        video
        video._.editing
        video._.transcoding
        video._.yt-dlp
        video._.mpv
        video._.obs
      ];
    };
  };
}
