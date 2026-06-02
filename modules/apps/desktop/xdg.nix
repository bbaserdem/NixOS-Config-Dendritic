# XDG setup settings
{...}: {
  flake.modules = {
    # Nixos system-wide xdg portal settings
    nixos.xdg = {...}: {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
      };
    };

    # Home-manager settings
    homeManager.xdg = {
      lib,
      pkgs,
      ...
    } @ args: {
      config = lib.mkMerge [
        {
          # Enable XDG specification
          xdg = {
            enable = true;
          };
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (
            lib.mkMerge [
              {
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
                  # Default terminal open specification
                  terminal-exec = {
                    enable = true;
                  };
                };
              }
              (
                # Let OS manage portal if we are nixos module
                lib.mkIf (lib.hasAttrByPath ["osConfig"] args) {
                  xdg.portal.enable = false;
                }
              )
              (
                # If we are standalone, we want to enable portal management
                lib.mkIf (!(lib.hasAttrByPath ["osConfig"] args)) {
                  xdg.portal = {
                    enable = true;
                    xdgOpenUsePortal = true;
                  };
                }
              )
            ]
          )
        )
      ];
    };
  };
}
