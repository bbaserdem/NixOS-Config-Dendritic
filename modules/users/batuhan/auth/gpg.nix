# GPG configuration for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
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
