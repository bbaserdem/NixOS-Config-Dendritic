# Python plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.python = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        nvim-dap-python
        nvim-treesitter-parsers.python
        nvim-treesitter-parsers.ninja
      ];
      extraPackages = with pkgs.unstable; [
        ruff # Formatter/linter
        ty # LSP & type checker
        yq # yaml parser
        # uv and debugpy should be provided by the environment
      ];
    };
  };
}
