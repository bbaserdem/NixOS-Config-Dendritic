# Configuring zed editor
{...}: {
  # TODO: Zed darwin builds from cache, redo this to use nixpkgs in 26.05
  flake.modules.darwin.zed = {...}: {
    homebrew = {
      casks = [
        "zed"
      ];
    };
  };
  flake.modules.homeManager.zed = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.zed-editor = {
          enable = true;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.zed-editor = {
            # TODO: Zed darwin builds from cache, redo this to use nixpkgs in 26.05
            # package = pkgs.zed-editor;
            package = null;
          };
        }
      )
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.zed-editor = {
            package = pkgs.zed-editor-fhs;
          };
        }
      )
    ];
  };
}
