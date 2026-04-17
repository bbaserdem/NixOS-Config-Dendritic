# Fonts to install to system
{...}: {
  flake.modules = let
    fontPackages = {
      pkgs,
      lib,
      ...
    }:
      (with pkgs; [
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
        victor-mono
        noto-fonts
        source-serif-pro
        source-sans-pro
        curie # Bitmap fonts
        tamsyn
      ])
      ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
        # Broken on nix-darwin right now
        jetbrains-mono
      ]));
  in {
    # Include in system
    generic.fonts = {
      pkgs,
      lib,
      ...
    }: {
      environment.systemPackages = fontPackages {inherit pkgs lib;};
    };

    # Install to user
    homeManager.fonts = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = fontPackages {inherit pkgs lib;};
    };
  };
}
