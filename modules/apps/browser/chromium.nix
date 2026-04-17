# Chromium
{...}: {
  flake.modules = {
    # Chrome through brew on darwin; no darwin build in nixpkgs
    darwin.chromium = {...}: {
      homebrew = {
        casks = [
          "ungoogled-chromium"
        ];
      };
    };

    # In linux, install to user profile
    homeManager.chromium = {
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        {
          programs.chromium = {
            enable = true;
          };
        }
        (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.chromium.package = null;
        })
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.chromium.package = pkgs.ungoogled-chromium;
        })
      ];
    };
  };
}
