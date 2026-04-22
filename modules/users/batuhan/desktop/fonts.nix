# Keyboard config for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {pkgs, ...}: {
    home.packages = with pkgs; [
      local."iosevka/wolframite"
    ];
  };
}
