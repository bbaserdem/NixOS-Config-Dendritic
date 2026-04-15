# SSH common config
{...}: {
  flake.modules.homeManager.pass = {
    config,
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.password-store = {
          enable = true;
          settings = {
            PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
            PASSWORD_STORE_CLIP_TIME = "30";
            PASSWORD_STORE_GENERATED_LENGTH = "16";
          };
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.password-store.package = pkgs.pass.withExtensions (exts: [
            exts.pass-checkup
            exts.pass-tomb
            exts.pass-genphrase
            exts.pass-update
          ]);
        }
      )
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.password-store.package = pkgs.pass.withExtensions (exts: [
            exts.pass-checkup
            # exts.pass-tomb # Not available in nix-darwin
            exts.pass-genphrase
            exts.pass-update
          ]);
        }
      )
    ];
  };
}
