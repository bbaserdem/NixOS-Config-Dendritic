# Lean plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.lean = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        lean-nvim
      ];
      # LSP should be provided by the environment, in lean
      # extraPackages = with pkgs.unstable; [
      #   lean
      # ];
    };
  };
}
