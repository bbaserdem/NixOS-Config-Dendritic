# Music related apps
{...}: {
  flake.modules.homeManager.audio = {
    pkgs,
    lib,
    ...
  }: {
    # Install these apps to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
          streamrip # Music downloader
          audacity # Audio editor
          musescore # Score editing
          picard # Tag music
          chromaprint # Calculate acoustic id
        ];
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            cantata
            prejectm-sdl-cpp # Broken on darwin
          ];
        }
      )
    ];
  };
}
