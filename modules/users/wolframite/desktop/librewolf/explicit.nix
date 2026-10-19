# Configuring librewolf explicit profile
{...}: {
  flake.modules.homeManager.wolframite-librewolf = {
    lib,
    options,
    pkgs,
    ...
  }: {
    config =
      lib.optionalAttrs
      ((options.local or {}) ? librewolf)
      {
        local.librewolf.profiles.explicit = {
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            video-downloadhelper
          ];
        };
      };
  };
}
