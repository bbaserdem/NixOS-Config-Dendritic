# Configuring kitty terminal
{inputs, ...}: {
  den = {
    aspects.applications = {
      provides.ghostty = {
        provides.to-users = {
          host,
          user,
        }: {
          # Dedupe guard
          name = "applications/ghostty(${user.userName}@${host.name})";
          # Darwin; pull from homebrew
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.ghostty-settings
            ];
          };
          # Home manager settings
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.ghostty-settings
            ];
          };
          # Stylix
          stylix = {
            targets.ghostty = {
              enable = true;
              colors.enable = true;
              fonts.enable = true;
              opacity.enable = true;
            };
          };
        };
      };
    };
  };

  # In darwin there is no nixpkgs; pull from brew
  flake.modules.darwin.ghostty-settings = {...}: {
    key = "ghostty-settings#darwin";
    config = {
      homebrew.casks = ["ghostty"];
    };
  };

  # Module enable
  flake.modules.homeManager.ghostty-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "ghostty-settings#homeManager";
    config = lib.mkMerge [
      {
        # Common settings
        programs.ghostty = {
          enable = true;
          # Settings
          settings = {
            font-codepoint-map = [
              # Nerd Font override
              # https://github.com/ryanoasis/nerd-fonts/wiki/Glyph-Sets-and-Code-Points
              # Seti-UI + Custom
              "U+E5FA-U+E6B7=Symbols Nerd Font Mono"
              # Devicons
              "U+E700-U+E8EF=Symbols Nerd Font Mono"
              # Font Awesome
              "U+ED00-U+F2FF=Symbols Nerd Font Mono"
              # Font Awesome Extension
              "U+E200-U+E2A9=Symbols Nerd Font Mono"
              # Material Design Icons
              "U+F0001-U+F1AF0=Symbols Nerd Font Mono"
              # Weather
              "U+E300-U+E3E3=Symbols Nerd Font Mono"
              # Octicons
              "U+F400-U+F532=Symbols Nerd Font Mono"
              "U+2665=Symbols Nerd Font Mono"
              "U+26A1=Symbols Nerd Font Mono"
              # [Powerline Symbols]
              "U+E0A0-U+E0A2=Symbols Nerd Font Mono"
              "U+E0B0-U+E0B3=Symbols Nerd Font Mono"
              # Powerline Extra Symbols
              "U+E0A3=Symbols Nerd Font Mono"
              "U+E0B4-U+E0C8=Symbols Nerd Font Mono"
              "U+E0CA=Symbols Nerd Font Mono"
              "U+E0CC-U+E0D7=Symbols Nerd Font Mono"
              "U+2630=Symbols Nerd Font Mono"
              # IEC Power Symbols
              "U+23FB-U+23FE=Symbols Nerd Font Mono"
              "U+2B58=Symbols Nerd Font Mono"
              # Font Logos (Formerly Font Linux)
              "U+F300-U+F381=Symbols Nerd Font Mono"
              # Pomicons
              "U+E000-U+E00A=Symbols Nerd Font Mono"
              # Codicons
              "U+EA60-U+EC1E=Symbols Nerd Font Mono"
              # Heavy Angle Brackets
              "U+276C-U+2771=Symbols Nerd Font Mono"
              # Box Drawing
              "U+2500-U+259F=Symbols Nerd Font Mono"
              # Progress
              "U+EE00-U+EE0B=Symbols Nerd Font Mono"
            ];
          };
        };
      }
      (
        # Linux only settings
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          programs.ghostty = {
            # Package pull from nixpkgs
            packages = pkgs.ghostty;

            # Integration only available if ghostty.package != null
            installVimSyntax = true;
            installBatSyntax = true;

            # Systemd integration
            systemd.enable = true;
            settings = {
              linux-cgroup = "single-instance";
            };
          };
        }
      )
      (
        # MacOS only settings
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.ghostty = {
            # Ghostty builds in linux only; we pull from homebrew instead
            package = null;

            # Mac-only settings
            settings = {
              macos-option-as-alt = true;
            };
          };
        }
      )
    ];
  };
}
