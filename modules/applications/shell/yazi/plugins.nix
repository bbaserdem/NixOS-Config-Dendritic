# Plugins for yazi
{...}: {
  flake.wrappers.yazi = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        plugins = with pkgs.yaziPlugins; {
          # UI
          git = git;
          starship = starship;
          split-tabs = split-tabs;
          full-border = full-border;
          # Behavior
          smart-enter = smart-enter;
          mount = mount;
          # Sessions persistence
          projects = projects;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          plugins = with pkgs.yaziPlugins; {
            mactag = mactag;
          };
        }
      )
    ];
  };
}
