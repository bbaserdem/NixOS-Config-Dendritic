# KDE-Connect: Connect to android
{...}: {
  flake.modules = {
    # Needs to be setup on nixos level
    nixos.kdeconnect = {...}: {
      programs.kdeconnect = {
        enable = true;
      };
    };
  };
}
