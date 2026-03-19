# Filetype conversion plugins
# Allows for auto-changing tags
{...}: {
  flake.modules.home-manager.beets = {
    pkgs,
    config,
    ...
  }: {
    # This is basically the yaml array written in nix
    programs.beets = {
      settings = {
        plugins = [
          "convert"
          "alternatives"
        ];

        # Conversion settings; use our conversion scripts
        convert = {
          auto = false;
          copy_album_art = true;
          album_art_maxwidth = 256;
          dest = "${config.xdg.userDirs.extraConfig.XDG_MEDIA_DIR}/Music (Lossy)";
          never_convert_lossy_files = true;
          embed = true;
          delete_originals = false;
          format = "opus";
          formats = {
            opus = {
              command = "${pkgs.user-audio}/bin/audio-convert2opus $source $dest";
              extension = "opus";
            };
          };
        };

        # Alternatives, this allows us to encode subsets of library
        types = {
          phone = "bool";
        };
        alternatives = {
          phone = {
            directory = "${config.xdg.userDirs.extraConfig.XDG_PHONE_DIR}/Music";
            formats = "opus mp3 ogg";
            query = "phone:True";
            removable = false;
          };
        };
      };
    };
  };
}
