# Direnv setup
{...}: {
  flake.modules.homeManager.batuhan = {
    config,
    pkgs,
    ...
  }: {
    # Auto allow in projects dir
    programs.direnv.config.whitelist = {
      prefix = [
        (
          if (pkgs.stdenv.hostPlatform.isLinux)
          then config.xdg.userDirs.extraConfig.XDG_PROJECTS_DIR
          else "${config.home.homeDirectory}/Projects"
        )
      ];
      exact = [];
    };
  };
}
