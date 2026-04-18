# Configuring kitty for batuhan
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    config,
    pkgs,
    ...
  }: let
    base16 = pkgs.callPackage inputs.base16.lib {};
    schemes = "${pkgs.base16-schemes}/share/themes";
    renderKitty = schemePath:
      ((base16.mkSchemeAttrs schemePath).override {}) {
        templateRepo = inputs.tinted-terminal;
        target = "kitty-base16";
        "check-parsed-config-yaml" = false;
      };
    stylixKitty = config.lib.stylix.colors {
      templateRepo = inputs.tinted-terminal;
      target = "kitty-base16";
      "check-parsed-config-yaml" = false;
    };
  in {
    # Override kitty settings from stylix
    stylix.targets.kitty.fonts.override = {
      monospace = {
        name = "Iosevka Light";
        package = pkgs.iosevka;
      };
      sizes.terminal = 13;
    };

    # Additional settings for kitty
    programs.kitty = {
      # Settings
      extraConfig = ''
        # Iosevka overrides
        bold_font           Iosevka Heavy
        italic_font         Iosevka Light Italic
        bold_italic_font    Iosevka ExtraBold Oblique
        font_features       Iosevka-Light               +dlig +ss05
        font_features       Iosevka-Heavy               +dlig +ss05
        font_features       Iosevka-Light-Italic        +dlig +ss05
        font_features       Iosevka-ExtraBold-Oblique   +dlig +ss05
      '';
    };

    # Enable color switching by dropping theme files
    xdg.configFile = {
      "kitty/dark-theme.auto.conf".source = renderKitty "${schemes}/gruvbox-dark-medium.yaml";
      "kitty/light-theme.auto.conf".source = renderKitty "${schemes}/gruvbox-light-medium.yaml";
      "kitty/no-preference-theme.auto.conf".source = stylixKitty;
    };
  };
}
