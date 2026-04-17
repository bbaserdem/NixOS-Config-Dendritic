# Google Chrome
{...}: {
  flake.modules = {
    # Chrome through brew on darwin; no darwin build in nixpkgs
    darwin.chrome = {...}: {
      homebrew = {
        casks = [
          "google-chrome"
        ];
      };
    };

    # In linux, install to user profile
    homeManager.chrome = {
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            google-chrome # Google chrome package; no home-manager module
          ];
        })
      ];
    };
  };
}
