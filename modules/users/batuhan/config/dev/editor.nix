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
      {
        programs.neovide.settings = {
          font = {
            size = 14;
            hinting = "full";
            edging = "antialias";
            normal = [
              {
                family = "Victor Mono";
                style = "Light";
              }
              {
                family = "Symbols Nerd Font Mono";
              }
            ];
            bold = [
              {
                family = "Victor Mono";
                style = "Bold";
              }
              {
                family = "Symbols Nerd Font Mono";
              }
            ];
            italic = [
              {
                family = "Victor Mono";
                style = "Light Oblique";
              }
              {
                family = "Symbols Nerd Font Mono";
              }
            ];
            bold_italic = [
              {
                family = "Victor Mono";
                style = "Bold Italic";
              }
              {
                family = "Symbols Nerd Font Mono";
              }
            ];
          };
        };
      }
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
