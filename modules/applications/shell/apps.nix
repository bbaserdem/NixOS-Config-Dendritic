# Shell apps to install
{...}: {
  flake.modules.homeManager.shell-apps = {pkgs, ...}: {
    key = "shell-apps#homeManager";
    config = {
      home.packages = with pkgs; [
        skim # Cmdline fuzzy finder
        tree # Directory display
      ];
    };
  };
}
