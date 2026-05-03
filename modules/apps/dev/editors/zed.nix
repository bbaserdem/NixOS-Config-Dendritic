# Configuring zed editor
{...}: {
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
            package = pkgs.zed-editor;
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
