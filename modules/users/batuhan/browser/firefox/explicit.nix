# Configuring firefox explicit profile
{...}: {
  localConfig.users.batuhan.firefox.profiles.explicit = {
    extensions.packages = {pkgs, ...}:
      with pkgs.nur.repos.rycee.firefox-addons; [
        video-downloadhelper
      ];
  };
}
