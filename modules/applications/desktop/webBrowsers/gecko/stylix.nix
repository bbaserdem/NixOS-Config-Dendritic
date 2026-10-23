# Stylix settings for gecko managed profiles
{inputs, ...}: {
  flake.modules.homeManager.gecko-profiles = {
    config,
    options,
    pkgs,
    lib,
    ...
  }: let
    base16-lib = pkgs.callPackage inputs.base16.lib {};
  in {
    key = "gecko-profiles/stylix#homeManager";
    config = lib.optionalAttrs (options ? stylix) (
      lib.mkIf (config.gecko.enable or false) (
        let
          # Profiles with stylix enabled; stripped to the stylix information
          stylixProfiles =
            config.gecko.profiles
            |> lib.mapAttrs (_: p: p.stylix or {})
            |> lib.filterAttrs (_: s: (s.enable or false));

          # Profiles to override stylix settings
          stylixProfileOverrides =
            stylixProfiles
            |> lib.filterAttrs (_: s: (s.themeOverride != null))
            |> lib.mapAttrs (name: s: (
              let
                palette = base16-lib.mkSchemeAttrs s.themeOverride;
              in {
                # Theme is an attrset to be dispatched to profile settings
                title = "Stylix ${palette.description}";
                images.additional_backgrounds = ["./bg-000.svg"];
                colors =
                  {
                    toolbar = "base00";
                    toolbar_text = "base05";
                    frame = "base01";
                    tab_background_text = "base05";
                    toolbar_field = "base02";
                    toolbar_field_text = "base05";
                    tab_line = "base0D";
                    popup = "base00";
                    popup_text = "base05";
                    button_background_active = "base04";
                    frame_inactive = "base00";
                    icons_attention = "base0D";
                    icons = "base05";
                    ntp_background = "base00";
                    ntp_text = "base05";
                    popup_border = "base0D";
                    popup_highlight_text = "base05";
                    popup_highlight = "base04";
                    sidebar_border = "base0D";
                    sidebar_highlight_text = "base05";
                    sidebar_highlight = "base0D";
                    sidebar_text = "base05";
                    sidebar = "base00";
                    tab_background_separator = "base0D";
                    tab_loading = "base05";
                    tab_selected = "base00";
                    tab_text = "base05";
                    toolbar_bottom_separator = "base00";
                    toolbar_field_border_focus = "base0D";
                    toolbar_field_border = "base00";
                    toolbar_field_focus = "base00";
                    toolbar_field_highlight_text = "base00";
                    toolbar_field_highlight = "base0D";
                    toolbar_field_separator = "base0D";
                    toolbar_vertical_separator = "base0D";
                  }
                  |> lib.mapAttrs (_: color: {
                    r = palette."${color}-rgb-r";
                    g = palette."${color}-rgb-g";
                    b = palette."${color}-rgb-b";
                  });
              }
            ));

          # Settings to set stylix targets to
          targetSettings = {
            enable = lib.mkOverride 1400 (stylixProfiles != {});
            profileNames = builtins.attrNames stylixProfiles;
          };
        in (
          lib.mkMerge [
            {
              # Report enabled profiles to stylix for theming
              stylix.targets =
                lib.genAttrs
                config.gecko.configuredBrowsers
                (b: lib.mkIf config.programs.${b}.enable targetSettings);
            }
            {
              # Dispatch theme setting overrides
              programs =
                lib.genAttrs
                config.gecko.configuredBrowsers
                (
                  b:
                    lib.mkIf
                    (
                      config.programs.${b}.enable
                      && config.stylix.targets.${b}.enable
                      && config.stylix.targets.${b}.inputs.enable
                      && config.stylix.targets.${b}.colors.enable
                      && config.stylix.targets.${b}.colorTheme.enable
                    )
                    {
                      profiles =
                        stylixProfileOverrides
                        |> lib.mapAttrs (n: theme: {
                          extensions.settings."FirefoxColor@mozilla.com".settings.theme =
                            lib.mkOverride 55 theme;
                        });
                    }
                );
            }
          ]
        )
      )
    );
  };
}
