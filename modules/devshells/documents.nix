# Dev shell for dealing with documents
{...}: {
  perSystem = {pkgs, ...}: {
    devShells.documents = pkgs.mkShell {
      packages = with pkgs; [
        # PDF
        poppler-utils
        qpdf
        exiftool
        # DjVu
        djvulibre
        # PostScript
        ghostscript
        # OCR
        tesseract
        ocrmypdf
        # Archives
        unzip
        gzip
        p7zip
        # General inspection / scripting
        file
        jq
        ripgrep
        # Python tooling
        uv
        # calibre CLI
        calibre
      ];
    };
  };
}
