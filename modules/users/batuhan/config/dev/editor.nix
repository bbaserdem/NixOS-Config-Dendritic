# Configuring system editor
{...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    ...
  }: {
    # Use this module only iF the wrapper module is defined
    # This will only happen if the neovim module is loaded
    config = lib.mkMerge [
      {}
      (
        lib.optionalAttrs (lib.attrsets.hasAttrPath ["wrappers" "neovim"] options) {
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
        }
      )
    ];
  };
}
