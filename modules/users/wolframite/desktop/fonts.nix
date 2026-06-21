# Keyboard config for wolframite
{...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Taxes memory too much to build
      # local."iosevka/wolframite"
    ];
  };
}
