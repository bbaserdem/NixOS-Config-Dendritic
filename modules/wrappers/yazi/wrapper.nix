# modules/wrappers/yazi/wrapper.nix
{...}: {
  flake.wrappers.yazi = {
    pkgs,
    config,
    wlib,
    lib,
    ...
  }: {
    imports = [
      wlib.wrapperModules.yazi
    ];

    config = {
      package = lib.mkDefault pkgs.yazi;

      # The init.lua file
      constructFiles.init_lua = {
        relPath = "${config.binName}-config/init.lua";
        content = builtins.readFile ./init.lua;
      };

      settings.yazi = {
        mgr.show_symlink = true;
        preview.wrap = "no";

        opener = {
          play = [
            {
              run = "mpv \"$@\"";
              desc = "Play using mpv";
              orphan = true;
            }
          ];

          edit = [
            {
              run = "$EDITOR \"$@\"";
              desc = "Edit file";
              block = true;
            }
          ];

          open = [
            {
              run = "xdg-open \"$@\"";
              desc = "Open using XDG";
              for = "linux";
            }
          ];
        };
      };

      runtimePkgs = with pkgs; [
        fd
        ripgrep
        fzf
        zoxide
        jq
        poppler
        ffmpegthumbnailer
        p7zip
        ouch
      ];
    };
  };
}
