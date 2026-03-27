# Bash config
{...}: {
  flake.modules.homeManager.shell = {...}: {
    # Integrations
    home.shell.enableBashIntegration = true;
    programs.fzf.enableBashIntegration = true;
    programs.direnv.enableBashIntegration = true;
    programs.ghostty.enableBashIntegration = true;
    programs.kitty.shellIntegration.enableBashIntegration = true;
    programs.nix-index.enableBashIntegration = true;
    programs.starship.enableBashIntegration = true;
    programs.yazi.enableBashIntegration = true;
    programs.zoxide.enableBashIntegration = true;

    # Setup zsh
    programs.bash = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      historyControl = ["ignoredups"];
    };
  };
}
