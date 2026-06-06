# Configuring firefox preferences for profile: explicit
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    programs.firefox.profiles.explicit = {
      # Profile specific settings

      # Extensions
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        video-downloadhelper
      ];

      # Search engines
      search.engines = {
        # Builtin engines
        amazondotcom-us.metaData = {
          alias = "@a";
          hidden = false;
        };
        bing.metaData = {
          alias = "@b";
          hidden = true;
        };
        ddg.metaData = {
          alias = "@d";
          hidden = false;
        };
        wikipedia.metaData = {
          alias = "@w";
          hidden = false;
        };
        ebay.metaData = {
          alias = "@eb";
          hidden = true;
        };
        ecosia.metaData = {
          alias = "@ec";
          hidden = false;
        };
        qwant.metaData = {
          alias = "@qw";
          hidden = false;
        };
        reddit.metaData = {
          alias = "@r";
          hidden = false;
        };
        youtube.metaData = {
          alias = "@y";
          hidden = false;
        };
      };
    };
  };
}
