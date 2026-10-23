# Work profile
{...}: {
  flake.modules.homeManager.wolframite-gecko = {
    lib,
    options,
    pkgs,
    ...
  }: {
    key = "wolframite-gecko/work#homeManager";
    config =
      lib.optionalAttrs
      (options ? gecko)
      {
        gecko.profiles.work = {
          # Custom containers
          containers = {
          };
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            catppuccin-web-file-icons
            enhanced-github
            private-grammar-checker-harper
            zotero-connector
          ];
        };
      };
  };
}
