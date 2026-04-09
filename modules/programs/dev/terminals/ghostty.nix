# Configuring ghostty
{...}: {
  flake.modules = {
    # Install through brew in nix-darwin
    darwin.ghostty = {...}: {
      homebrew.casks = [
        "ghostty"
      ];
    };

    # Home manager configuration
    homeManager = {
      # Enable stylix theming for ghostty
      stylix = {...}: {
        stylix.targets.ghostty = {
          enable = true;
        };
      };

      # Kitty settings
      ghostty = {
        pkgs,
        lib,
        ...
      }: {
        config = lib.mkMerge [
          {
            programs.ghostty = {
              enable = true;

              # Integrations
              installVimSyntax = true;
              installBatSyntax = true;

              # Settings
              settings = {
              };
            };
          }
          (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Linux only settings
            programs.ghostty = {
              systemd.enable = true;
              settings = {
                linux-cgroup = "single-instance";
              };
            };
          })
          (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
            # MacOS only settings
            programs.ghostty = {
              # Ghostty is linux only
              package = null;
              settings = {
                macos-option-as-alt = true;
              };
            };
          })
        ];
      };
    };
  };
}
