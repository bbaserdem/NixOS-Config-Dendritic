# Filetype conversion plugins
{inputs, ...}: {
  flake.modules.homeManager.wolframite-beets = {
    pkgs,
    config,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.beets.settings = {
          plugins = [
            "convert"
            "alternatives"
          ];

          # Conversion settings; use our conversion scripts
          # Outputs to a folder named Lossy
          convert = {
            auto = false;
            copy_album_art = true;
            album_art_maxwidth = 256;
            dest = "${config.programs.beets.settings.directory}/Lossy";
            never_convert_lossy_files = true;
            embed = true;
            delete_originals = false;
            format = "opus";
            formats = {
              opus = {
                command =
                  "${pkgs.local.audman}/bin/audman convert lossy "
                  + "--single --force "
                  + "--input-file $source --output-file $dest";
                extension = "opus";
              };
              flac = {
                command =
                  "${pkgs.local.audman}/bin/audman convert lossless "
                  + "--single "
                  + "--input-file $source --output-file $dest";
                extension = "flac";
              };
            };
          };

          # Alternatives, this allows us to encode subsets of library
          alternatives = {
            mobile = {
              directory = "Mobile";
              formats = ["opus" "mp3" "ogg"];
              query = "lossy:true";
              removable = false;
              album_art_embed = true;
              album_art_copy = true;
              album_art_maxwidth = 500;
              album_art_format = "jpg";
            };
          };

          # Add the lossy directories to beets global ignore
          ignore = [
            "Lossy"
            "Mobile"
          ];
        };
      }
    ];
  };
}
