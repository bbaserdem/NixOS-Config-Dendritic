# Configuring the editor, using the neovim wrapper from this flake
# Important; the name nvim is crucial to distinguish from the neovim wrapper
{...}: {
  flake.modules.homeManager.vscode = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.vscode = {
          enable = true;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.vscode = {
            package = pkgs.vscodium;
          };
        }
      )
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.vscode = {
            package = pkgs.vscodium-fhs;
          };
        }
      )
    ];
  };
}
