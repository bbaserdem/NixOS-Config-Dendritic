# Filetype conversion plugins
# Allows for auto-changing tags
{...}: {
  flake.modules.homeManager.wolframite = {
    pkgs,
    config,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        # This is basically the yaml array written in nix
        programs.beets.settings = {
          plugins = [
            "convert"
            "alternatives"
          ];

          # Conversion settings; use our conversion scripts
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
                command = "${pkgs.local.audio-scripts}/bin/audio-convert2opus $source $dest";
                extension = "opus";
              };
            };
          };

          # Alternatives, this allows us to encode subsets of library
          alternatives = {
            lossy = {
              directory = "Lossy";
              formats = ["opus" "mp3" "ogg"];
              query = "lossy:true collection:=Main , lossy:true collection::^$";
              removable = false;
              album_art_embed = true;
              album_art_copy = true;
              album_art_maxwidth = 500;
              album_art_format = "jpg";
            };
          };
          ignore = [
            "Lossy"
          ];
        };
      }
      (
        let
          homeDir = config.home.homeDirectory;
          musicDir = config.programs.beets.settings.directory;
        in
          # Dispatch .mpdignore file, excluding some hosts
          lib.mkIf
          (
            (lib.hasPrefix "${homeDir}/" musicDir)
            && (!(
              builtins.elem config.networking.hostName [
                "su-ana"
              ]
            ))
          ) {
            home.file."${lib.removePrefix "${homeDir}/" musicDir}/.mpdignore".text = ''
              Lossy
            '';
          }
      )
    ];
  };
}
