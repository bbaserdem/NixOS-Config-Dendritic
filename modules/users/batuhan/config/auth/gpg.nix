# GPG configuration for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          services.gpg-agent = {
            pinentry.package = pkgs.pinentry-gnome3;
          };
        }
      )
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          services.gpg-agent = {
            pinentry.package = pkgs.pinentry_mac;
          };
        }
      )
    ];
  };
}
