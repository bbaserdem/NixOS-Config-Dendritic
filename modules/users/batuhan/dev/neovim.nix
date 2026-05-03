# Configuring system editor
{...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    config,
    ...
  }: {
    config = lib.mkMerge [
      {
        # Configure neovide
        programs.neovide.settings = {
          font = {
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
        # Configure the neovim wrapper
        lib.optionalAttrs (lib.hasAttrByPath ["wrappers" "neovim"] options) {
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

          # Set neovim as default editor
          home.sessionVariables = {
            EDITOR = lib.getExe config.wrappers.neovim.wrapper;
          };
        }
      )
    ];
  };
}
