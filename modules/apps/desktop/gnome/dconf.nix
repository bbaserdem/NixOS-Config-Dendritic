# Dconf settings for default by gnome
{...}: {
  flake.modules.homeManager.gnome = {
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      dconf.settings = {
        # Disable gnome auto-mount behavior
        "org/gnome/desktop/media-handling" = {
          automount = false;
          automount-open = false;
          autorun-never = true;
        };
      };
    };
  };
}
