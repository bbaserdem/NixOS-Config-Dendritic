# Python plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.python = {
      lazy = true;
      data = with pkgs.vimPlugins; [
        nvim-dap-python
      ];
      extraPackages = with pkgs; [
        ruff
        ty
      ];
    };
  };
}
