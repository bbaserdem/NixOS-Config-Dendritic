# Configuring firefox explicit profile
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
        local.firefox.profiles.explicit = {
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            video-downloadhelper
          ];
        };
      };
  };
}
