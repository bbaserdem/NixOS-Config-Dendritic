# Yazi fetcher plugins
{...}: {
  flake.wrappers.yazi = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        settings.yazi.plugin.prepend_fetchers = [
          {
            url = "*";
            run = "git";
            group = "git";
          }
          {
            url = "*/";
            run = "git";
            group = "git";
          }
        ];
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          settings.yazi.plugin.prepend_fetchers = [
            {
              url = "*";
              run = "mactag";
            }
            {
              url = "*/";
              run = "mactag";
            }
          ];
        }
      )
    ];
  };
}
