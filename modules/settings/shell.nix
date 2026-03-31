# Configure default shell for users
{...}: {
  flake.modules = {
    # Set shells to be used

    # Set zsh as default shell
    nixos.shell = {pkgs, ...}: {
      users.defaultUserShell = pkgs.zsh;
    };

    # Darwin doesn't have a default shell option
  };
}
