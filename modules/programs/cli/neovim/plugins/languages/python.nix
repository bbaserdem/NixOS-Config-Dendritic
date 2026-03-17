# Python plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.python = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-dap-python
      ];
      extraPackages = with pkgs; [
        ruff # Formatter/linter
        ty # LSP & type checker
        yq # yaml parser
        # uv and debugpy should be provided by the environment
      ];
    };
  };
}
