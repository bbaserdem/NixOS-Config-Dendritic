# Shell editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.shell = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-treesitter-parsers.bash
        nvim-treesitter-parsers.zsh
        nvim-treesitter-parsers.fish
        nvim-treesitter-parsers.nu
      ];
      extraPackages = with pkgs.unstable; [
        bash
        dash
        dotenv-linter
        shellcheck
      ];
    };
  };
}
