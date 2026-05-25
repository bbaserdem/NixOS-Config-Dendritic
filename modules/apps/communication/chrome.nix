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
          # We just install to user-space
          # the chromium module doesn't work well on chrome anyway
          home.packages = with pkgs; [
            google-chrome
          ];
        })
      ];
    };
  };
}
