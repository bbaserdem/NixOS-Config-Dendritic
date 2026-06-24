# Gnome configuration
{...}: {
  flake.modules.homeManager.gnome = {
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      # Some gnome extensions
      programs.gnome-shell = {
        extensions = with pkgs.gnomeExtensions; [
          # Status tray
          {package = appindicator;}
          # Battery of wireless devices shown
          {package = wireless-hid;}
          # Menu for removable drives
          {package = removable-drive-menu;}
          # Shows system resources
          {package = vitals;}
          # Clipboard
          {package = clipboard-indicator;}
          # MacOS like dock
          {package = dash2dock-lite;}
          # UI candy for top bar
          {package = open-bar;}
          # Tiling
          {package = tiling-shell;}
          # mpdris media controls
          {package = media-controls;}
          {package = dynamic-music-pill;}
        ];
      };
    };
  };
}
