# Firefox work profile for batuhan
{...}: {
  flake.modules.homeManager.firefox-wolframite = {
    lib,
    options,
    pkgs,
    ...
  }: {
    config =
      lib.optionalAttrs
      ((options.local or {}) ? firefox)
      {
        local.firefox.profiles.work = {
          # Custom containers
          containers = {
            superbuilders = {
              name = "SuperBuilders";
              id = 1;
              icon = "briefcase";
              color = "yellow";
            };
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
