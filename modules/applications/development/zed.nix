# Configuring Zed
{...}: {
  flake.modules.homeManager.zed-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "zed-settings#homeManager";
    config = lib.mkMerge [
      {
        programs.zed-editor = {
          enable = true;
        };
      }
      (
        # Darwin should get the regular zed from nixpkgs
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.zed-editor = {
            package = pkgs.zed-editor;
          };
        }
      )
      (
        # In Linux, we need fhs to make plugins work
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.vscodium = {
            package = pkgs.zed-editor-fhs;
          };
        }
      )
    ];
  };
}
