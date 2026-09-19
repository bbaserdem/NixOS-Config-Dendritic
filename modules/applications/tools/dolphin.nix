# Filesystem navigation
{...}: {
  flake.modules.homeManager.dolphin-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "dolphin-settings#homeManager";
    # Install dolphin to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
        ];
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          kdePackages.dolphin # File browser
        ];
      })
    ];
  };
}
