# Shell apps to install
{...}: {
  flake.modules.homeManager.shell-apps = {pkgs, ...}: {
    home.packages = with pkgs; [
      skim # Cmdline fuzzy finder
      tree # Directory display
    ];
  };
}
