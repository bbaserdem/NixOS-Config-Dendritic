# Python plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.python = {
      lazy = true;
      data = with pkgs.unstable.vimPlugins; [
        nvim-dap-python
      ];
      runtimePackages = with pkgs.unstable; [
        ruff # Formatter/linter
        ty # LSP & type checker
        yamllint # yaml parser
        # uv and debugpy should be provided by the environment
      ];
    };
  };
}
