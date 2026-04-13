# Configuring kitty for batuhan
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    config,
    pkgs,
    lib,
    ...
  }: let
    base16 = inputs.base16.lib {inherit pkgs lib;};
    # Parse scheme YAML inta a callable colors object
    mkColors = schemePath: (base16.mkSchemeAttrs schemePath).override {};
    # Render kitty theme file using tinted-terminal templates
    mkKittyTheme = schemePath:
      (mkColors schemePath) {
        templateRepo = inputs.tinted-terminal;
        target = "kitty-base16";
      };
    # mkSchemes
    schemes = "${pkgs.base16-schemes}/share/themes";
  in {
    # # Override kitty settings from stylix
    # stylix.targets.kitty.fonts.override = {
    #   monospace = {
    #     name = "Iosevka Light";
    #     package = pkgs.iosevka;
    #   };
    #   sizes.terminal = 13;
    # };

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
      "kitty/dark-theme.auto.conf".source = mkKittyTheme "${schemes}/gruvbox-dark-medium.yaml";
      "kitty/light-theme.auto.conf".source = mkKittyTheme "${schemes}/gruvbox-light-medium.yaml";
      # "kitty/no-preference-theme.auto.conf".source = config.lib.stylix.colors {
      #   templateRepo = inputs.tinted-terminal;
      #   target = "kitty-base16";
      # };
    };
  };
}
