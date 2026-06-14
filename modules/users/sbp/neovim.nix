# Configuring editor for SBP
{...}: {
  flake.modules.homeManager.sbp = {
    lib,
    options,
    config,
    ...
  }: {
    # Configure the neovim wrapper
    config = lib.optionalAttrs (lib.hasAttrByPath ["wrappers" "neovim"] options) {
      wrappers.neovim = {
        # Set default theme
        settings = {
          colorscheme = {
            dark = "onedark";
            light = "kanagawa-lotus";
            translucent = true;
            default = "dark";
          };
        };
      };

      # Set neovim as default editor
      home.sessionVariables = {
        EDITOR = lib.getExe config.wrappers.neovim.wrapper;
      };
    };
  };
}
