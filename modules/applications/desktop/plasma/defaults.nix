# Plasma desktop default apps list
{...}: {
  flake.modules.homeManager.plasma-defaults = {
    lib,
    pkgs,
    ...
  }: {
    key = "plasma-defaults#homeManager";
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      xdg.configFile."kde-mimeapps.list".text = ''
        [Default Applications]

        # File browser: Dolphin
        inode/directory=org.kde.dolphin.desktop

        # Archives: Ark
        application/gzip=org.kde.ark.desktop
        application/vnd.debian.binary-package=org.kde.ark.desktop
        application/vnd.ms-cab-compressed=org.kde.ark.desktop
        application/vnd.rar=org.kde.ark.desktop
        application/x-7z-compressed=org.kde.ark.desktop
        application/x-archive=org.kde.ark.desktop
        application/x-arj=org.kde.ark.desktop
        application/x-bzip=org.kde.ark.desktop
        application/x-bzip2=org.kde.ark.desktop
        application/x-bzip-compressed-tar=org.kde.ark.desktop
        application/x-bzip2-compressed-tar=org.kde.ark.desktop
        application/x-cd-image=org.kde.ark.desktop
        application/x-compressed-tar=org.kde.ark.desktop
        application/x-cpio=org.kde.ark.desktop
        application/x-cpio-compressed=org.kde.ark.desktop
        application/x-deb=org.kde.ark.desktop
        application/x-java-archive=org.kde.ark.desktop
        application/x-lha=org.kde.ark.desktop
        application/x-lrzip=org.kde.ark.desktop
        application/x-lrzip-compressed-tar=org.kde.ark.desktop
        application/x-lz4=org.kde.ark.desktop
        application/x-lz4-compressed-tar=org.kde.ark.desktop
        application/x-lzip=org.kde.ark.desktop
        application/x-lzip-compressed-tar=org.kde.ark.desktop
        application/x-lzma-compressed-tar=org.kde.ark.desktop
        application/x-lzop=org.kde.ark.desktop
        application/x-rar=org.kde.ark.desktop
        application/x-rpm=org.kde.ark.desktop
        application/x-source-rpm=org.kde.ark.desktop
        application/x-tar=org.kde.ark.desktop
        application/x-xar=org.kde.ark.desktop
        application/x-xz=org.kde.ark.desktop
        application/x-xz-compressed-tar=org.kde.ark.desktop
        application/x-zstd-compressed-tar=org.kde.ark.desktop
        application/zip=org.kde.ark.desktop
        application/zstd=org.kde.ark.desktop

        # Music: VLC
        application/ogg=org.kde.elisa.desktop
        application/x-extension-m4a=org.kde.elisa.desktop
        application/x-ogg=org.kde.elisa.desktop
        application/xspf+xml=org.kde.elisa.desktop
        audio/aac=org.kde.elisa.desktop
        audio/flac=org.kde.elisa.desktop
        audio/m4a=org.kde.elisa.desktop
        audio/mp4=org.kde.elisa.desktop
        audio/mpeg=org.kde.elisa.desktop
        audio/mpegurl=org.kde.elisa.desktop
        audio/ogg=org.kde.elisa.desktop
        audio/opus=org.kde.elisa.desktop
        audio/scpls=org.kde.elisa.desktop
        audio/vnd.rn-realaudio=org.kde.elisa.desktop
        audio/vorbis=org.kde.elisa.desktop
        audio/wav=org.kde.elisa.desktop
        audio/webm=org.kde.elisa.desktop
        audio/x-aac=org.kde.elisa.desktop
        audio/x-aiff=org.kde.elisa.desktop
        audio/x-flac=org.kde.elisa.desktop
        audio/x-m4a=org.kde.elisa.desktop
        audio/x-mp3=org.kde.elisa.desktop
        audio/x-mpeg=org.kde.elisa.desktop
        audio/x-mpegurl=org.kde.elisa.desktop
        audio/x-ms-wma=org.kde.elisa.desktop
        audio/x-musepack=org.kde.elisa.desktop
        audio/x-oggflac=org.kde.elisa.desktop
        audio/x-pn-realaudio=org.kde.elisa.desktop
        audio/x-scpls=org.kde.elisa.desktop
        audio/x-speex=org.kde.elisa.desktop
        audio/x-vorbis=org.kde.elisa.desktop
        audio/x-vorbis+ogg=org.kde.elisa.desktop
        audio/x-wav=org.kde.elisa.desktop

        # Images: Gwenview
        application/x-krita=org.kde.gwenview.desktop
        image/avif=org.kde.gwenview.desktop
        image/bmp=org.kde.gwenview.desktop
        image/gif=org.kde.gwenview.desktop
        image/heif=org.kde.gwenview.desktop
        image/jpeg=org.kde.gwenview.desktop
        image/jxl=org.kde.gwenview.desktop
        image/openraster=org.kde.gwenview.desktop
        image/png=org.kde.gwenview.desktop
        image/svg+xml=org.kde.gwenview.desktop
        image/svg+xml-compressed=org.kde.gwenview.desktop
        image/tiff=org.kde.gwenview.desktop
        image/webp=org.kde.gwenview.desktop
        image/x-icns=org.kde.gwenview.desktop
        image/x-ico=org.kde.gwenview.desktop
        image/x-portable-bitmap=org.kde.gwenview.desktop
        image/x-portable-graymap=org.kde.gwenview.desktop
        image/x-portable-pixmap=org.kde.gwenview.desktop
        image/x-psd=org.kde.gwenview.desktop
        image/x-tga=org.kde.gwenview.desktop
        image/x-webp=org.kde.gwenview.desktop
        image/x-xbitmap=org.kde.gwenview.desktop
        image/x-xcf=org.kde.gwenview.desktop
        image/x-xpixmap=org.kde.gwenview.desktop

        # Documents: Okular
        application/pdf=okularApplication_pdf.desktop
        application/x-bzpdf=okularApplication_pdf.desktop
        application/x-gzpdf=okularApplication_pdf.desktop
        application/x-wwf=okularApplication_pdf.desktop

        application/postscript=okularApplication_ghostview.desktop
        application/x-bzpostscript=okularApplication_ghostview.desktop
        application/x-gzpostscript=okularApplication_ghostview.desktop
        image/x-bzeps=okularApplication_ghostview.desktop
        image/x-eps=okularApplication_ghostview.desktop
        image/x-gzeps=okularApplication_ghostview.desktop

        image/vnd.djvu=okularApplication_djvu.desktop

        application/x-bzdvi=okularApplication_dvi.desktop
        application/x-dvi=okularApplication_dvi.desktop
        application/x-gzdvi=okularApplication_dvi.desktop

        application/oxps=okularApplication_xps.desktop
        application/vnd.ms-xpsdocument=okularApplication_xps.desktop

        application/epub+zip=okularApplication_epub.desktop
        application/x-fictionbook+xml=okularApplication_fb.desktop
        application/x-mobipocket-ebook=okularApplication_mobi.desktop

        application/x-cb7=okularApplication_comicbook.desktop
        application/x-cbr=okularApplication_comicbook.desktop
        application/x-cbt=okularApplication_comicbook.desktop
        application/x-cbz=okularApplication_comicbook.desktop

        # Map links: Marble
        x-scheme-handler/geo=org.kde.marble.desktop
        x-scheme-handler/worldwind=org.kde.marble.desktop
      '';
    };
  };
}
