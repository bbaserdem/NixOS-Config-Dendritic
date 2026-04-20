# Configuring chromium
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        }
      )
    ];
  };
}
