# Librewolf work profile for batuhan
{...}: {
  flake.modules.homeManager.librewolf-wolframite = {
    lib,
    options,
    pkgs,
    ...
  }: {
    config =
      lib.optionalAttrs
      ((options.local or {}) ? librewolf)
      {
        local.librewolf.profiles.work = {
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
