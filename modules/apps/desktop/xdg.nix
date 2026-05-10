# XDG setup settings
{...}: {
  flake.modules = {
    homeManager.xdg = {
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        {
          # Enable XDG specification
          xdg = {
            enable = true;
          };
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Linux-only functionality
            xdg = {
              # User directory specification
              userDirs = {
                enable = true;
                createDirectories = false; # Should be handled ourselves
              };
              # Autostart in linux
              autostart = {
                enable = true;
                readOnly = true;
              };
              # Mime type associations in linux
              mime = {
                enable = true;
              };
              mimeApps = {
                enable = true;
              };
              # Desktop integration
              portal = {
                enable = true;
                xdgOpenUsePortal = true;
              };
              # Default terminal open specification
              terminal-exec = {
                enable = true;
              };
            };
          }
        )
      ];
    };
  };
}
