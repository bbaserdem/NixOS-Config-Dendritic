# Configuring ghostty for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    programs.ghostty = lib.mkMerge [
      {
        # Settings
        settings = {
          theme = "light:Desert,dark:Selenized Light";
        };
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
        # MacOS only settings
        settings = {
          macos-icon = "microchip";
        };
      })
    ];
  };
}
