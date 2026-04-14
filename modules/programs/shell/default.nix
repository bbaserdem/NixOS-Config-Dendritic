# Default shell setting
{...}: {
  flake.modules = {
    nixos.shell = {pkgs, ...}: {
      # Set zsh as default shell
      users = {
        defaultUserShell = pkgs.zsh;
        # Set zsh as root shell too
        users.root.shell = pkgs.zsh;
      };
    };
  };
}
