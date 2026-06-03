# Configuring the editor, using the neovim wrapper from this flake
# Important; the name nvim is crucial to distinguish from the neovim wrapper
{...}: {
  flake.modules.homeManager.vscodium = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.vscodium = {
          enable = true;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.vscodium = {
            package = pkgs.vscodium;
          };
        }
      )
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.vscodium = {
            package = pkgs.vscodium-fhs;
          };
        }
      )
    ];
  };
}
