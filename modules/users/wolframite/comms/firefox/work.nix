# Firefox work profile for batuhan
{...}: {
  localConfig.users.wolframite.firefox.profiles.work = {
    # Custom containers
    containers = {
      superbuilders = {
        name = "SuperBuilders";
        id = 1;
        icon = "briefcase";
        color = "yellow";
      };

      erdos = {
        name = "Erdos";
        id = 2;
        icon = "fingerprint";
        color = "pink";
      };
    };

    # Extra extensions
    extensions.packages = {pkgs, ...}:
      with pkgs.nur.repos.rycee.firefox-addons; [
        catppuccin-web-file-icons
        enhanced-github
        private-grammar-checker-harper
        zotero-connector
      ];
  };
}
