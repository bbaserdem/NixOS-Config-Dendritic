# Configuring chromium
{...}: {
  flake.modules.homeManager.wolframite = {
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
