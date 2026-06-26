# General audio settings
{...}: {
  flake.modules.homeManager.wolframite = {pkgs, ...}: {
    # Install our script packgae
    home.packages = with pkgs; [
      local.audman
    ];
  };
}
