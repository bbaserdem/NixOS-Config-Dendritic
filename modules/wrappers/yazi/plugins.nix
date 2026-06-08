# modules/wrappers/yazi/plugins.nix
{...}: {
  flake.wrappers.yazi = {
    pkgs,
    lib,
    ...
  }: {
    plugins = with pkgs.yaziPlugins; (lib.mkMerge [
      {
        # UI
        git = git;
        starship = starship;
        split-tabs = split-tabs;
        full-border = full-border;
        # Behavior
        smart-enter = smart-enter;
        mount = mount;
        smart-paste = smart-paste;
        # Sessions persistence
        projects = projects;
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          mactag = mactag;
        }
      )
    ]);
  };
}
