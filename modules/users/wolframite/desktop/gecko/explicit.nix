# Configuring explicit profile
{...}: {
  flake.modules.homeManager.wolframite-gecko = {
    lib,
    options,
    pkgs,
    ...
  }: {
    key = "wolframite-gecko/explicit#homeManager";
    config =
      lib.optionalAttrs
      (options ? gecko)
      {
        gecko.profiles.explicit = {
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            video-downloadhelper
          ];
        };
      };
  };
}
