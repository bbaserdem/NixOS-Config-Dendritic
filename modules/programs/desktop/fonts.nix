# Fonts to install to system
{inputs, ...}: {
  flake.modules = let
    fontPackages = pkgs: (with pkgs; [
      nerd-fonts.symbols-only
      noto-fonts-monochrome-emoji # Emoji fonts
      noto-fonts-color-emoji
      _3270font # Monospace
      fira-code # Monospace with ligatures
      liberation_ttf # Windows compat.
      caladea #   Office fonts alternative
      carlito #   Calibri/georgia alternative
      inconsolata # Monospace font, for prints
      iosevka # Monospace font, for terminal mostly
      jetbrains-mono # Readable monospace font
      victor-mono
      noto-fonts
      source-serif-pro
      source-sans-pro
      curie # Bitmap fonts
      tamsyn
    ]);
  in {
    # Include in system
    generic.fonts = {pkgs, ...}: {
      environment.systemPackages = fontPackages pkgs;
    };

    # Install to user
    homeManager.fonts = {pkgs, ...}: {
      home.packages = fontPackages pkgs;
    };
  };
}
