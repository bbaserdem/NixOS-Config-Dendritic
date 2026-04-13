# Comm integration software suite
{...}: {
  flake.modules.homeManager.comms = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
          signal-desktop # Messaging
          zoom-us # Video conferancing
        ];
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          ferdium # Comms aggregator
        ];
      })
    ];
  };
}
