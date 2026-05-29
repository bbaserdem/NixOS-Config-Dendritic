# GPG configuration for wolframite
{inputs, ...}: {
  flake.modules.homeManager.wolframite = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.gpg = {
          publicKeys = [
            {
              source = inputs.self + /assets/wolframite/gpg-public.asc;
              trust = 5;
            }
          ];
        };
      }
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
