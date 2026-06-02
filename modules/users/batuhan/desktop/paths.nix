# Configuring user paths
{...}: {
  flake.modules.homeManager.batuhan = {
    config,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        # XDG paths
        xdg = {
          # Directories
          cacheHome = "${config.home.homeDirectory}/.cache";
          configHome = "${config.home.homeDirectory}/.config";
          dataHome = "${config.home.homeDirectory}/.local/share";
          stateHome = "${config.home.homeDirectory}/.local/state";
        };
        # Flake location
        home.sessionVariables = {
          NH_FLAKE = "${config.home.homeDirectory}/Projects/SystemConfigFlake";
          NH_OS_FLAKE = "${config.home.homeDirectory}/Projects/SystemConfigFlake";
        };
      }
    ];
  };
}
