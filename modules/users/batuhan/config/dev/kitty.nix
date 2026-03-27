# Configuring kitty for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    programs.kitty = {
      # We override stylix for our custom font
      font = lib.mkForce {
        #name = "Victor Mono";
        #package = pkgs.victor-mono;
        name = "Iosevka Light";
        package = pkgs.iosevka;
        size = 13;
      };

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
  };
}
