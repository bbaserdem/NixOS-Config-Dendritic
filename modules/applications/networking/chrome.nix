# Chrome and derivatives install setup
{...}: {
  flake.modules = {
    # Google chrome
    darwin.chrome-settings = {...}: {
      key = "chrome-settings#darwin";
      config = {
        homebrew.casks = ["google-chrome"];
      };
    };
    homeManager.chrome-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "chrome-settings#homeManager";
      config = lib.mkMerge [
        (
          # On darwin; chrome has to be from brew; on linux we install binary
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            home.packages = [pkgs.google-chrome];
          }
        )
      ];
    };

    # Chromium
    darwin.chromium-settings = {...}: {
      key = "chromium-settings#darwin";
      config = {
        homebrew.casks = ["ungoogled-chromium"];
      };
    };
    homeManager.chromium-settings = {
      pkgs,
      lib,
      ...
    }: {
      key = "chromium-settings#homeManager";
      config = lib.mkMerge [
        {
          programs.chromium.enable = true;
        }
        (
          # On linux, nixpkgs has ungoogled chromium
          lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
            programs.chromium.package = pkgs.ungoogled-chromium;
          }
        )
        (
          # On darwin, nixpkgs doesn't have ungoogled chromium
          lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
            programs.chromium.package = null;
          }
        )
      ];
    };
  };
}
