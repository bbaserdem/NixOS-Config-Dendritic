# Configuring VSCodium
{...}: {
  flake.modules.homeManager.vscodium-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "vscodium-settings#homeManager";
    config = lib.mkMerge [
      {
        programs.vscodium = {
          enable = true;
        };
      }
      (
        # Darwin should get the regular vscodium from nixpkgs
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.vscodium = {
            package = pkgs.vscodium;
          };
        }
      )
      (
        # In Linux, we need fhs to make plugins work
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.vscodium = {
            package = pkgs.vscodium-fhs;
          };
        }
      )
    ];
  };
}
