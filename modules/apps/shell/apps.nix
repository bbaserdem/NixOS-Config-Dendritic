# Shell apps to install
{...}: {
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.packages = with pkgs; [
      skim # Cmdline fuzzy finder
      tree # Directory display
    ];
  };
}
