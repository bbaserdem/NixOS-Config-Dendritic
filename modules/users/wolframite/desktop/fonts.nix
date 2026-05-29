# Keyboard config for wolframite
{...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    home.packages = with pkgs; [
      local."iosevka/wolframite"
    ];
  };
}
