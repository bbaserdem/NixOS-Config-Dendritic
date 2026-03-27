# Configuring system editor
{...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    config,
    ...
  }: {
    # Use this module only iF the wrapper module is defined
    # This will only happen if the neovim module is loaded
    config = lib.mkMerge [
      {}
      (
        lib.optionalAttrs (builtins.hasAttrPath ["wrappers" "neovim"] options) {
          wrappers.neovim = {
            # Set default theme
            settings = {
              colorscheme = {
                dark = "onedark";
                light = "kanagawa-lotus";
                translucent = false;
                default = "dark";
              };
            };
          };

          # Set editor
          home.sessionVariables = {
            EDITOR = lib.getExe config.wrappers.neovim.wrapper;
          };
        }
      )
    ];
  };
}
