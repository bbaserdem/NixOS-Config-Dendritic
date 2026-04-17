# Filesystem browsing programes
{...}: {
  flake.modules.homeManager.files = {
    pkgs,
    lib,
    ...
  }: {
    # Install these apps to userspace
    config = lib.mkMerge [
      {
        home.packages = with pkgs; [
        ];
      }
      (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        home.packages = with pkgs; [
          baobab # Disk usage analyzer
          kdePackages.dolphin # File browser
        ];
      })
    ];
  };
}
