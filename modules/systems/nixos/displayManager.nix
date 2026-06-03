# Display manager setup for nixos systems
{...}: {
  flake.modules.nixos = {
    nixos = {
      lib,
      config,
      options,
      pkgs,
      ...
    }: let
      cfg = config.local.displayManager;
    in {
      # Local option for hosts to set the display manager
      options = {
        local.displayManager = {
          name = lib.mkOption {
            type = lib.types.nullOr (lib.types.enum [
              "gdm"
              "sddm"
              "regreet"
              "plm"
            ]);
            default = null;
            description = ''
              Display manager to be used by the nixos system
            '';
          };
          config = lib.mkOption {
            type = lib.types.attrs;
            default = {};
            description = ''
              Config options to be passed to the display manager
            '';
          };
        };
      };

      # Application of the selected options
      config = lib.mkMerge [
        {
          services.displayManager.gdm.enable = lib.mkOverride 950 false;
          services.displayManager.sddm.enable = lib.mkOverride 950 false;
          programs.regreet.enable = lib.mkOverride 950 false;
          services.displayManager.plasma-login-manager.enable = lib.mkOverride 950 false;
        }
        # Configure enabled and other stuff
        (
          lib.mkIf (cfg.name == "gdm") {
            services.displayManager.gdm.enable = lib.mkOverride 900 true;
            services.displayManager.gdm = {
              wayland = true;
            };
          }
        )
        (
          lib.mkIf (cfg.name == "sddm") (lib.mkMerge [
            {
              services.displayManager.sddm.enable = lib.mkOverride 900 true;
              services.displayManager.sddm = {
                enableHidpi = true;
                wayland.enable = true;
                settings.General.InputMethod = "qtvirtualkeyboard";
              };
              environment.systemPackages = with pkgs; [
                kdePackages.qtvirtualkeyboard
              ];
            }
            (
              # Fallback theme if stylix is not available
              lib.mkIf (! (lib.hasAttrByPath ["stylix"] options)) {
                services.displayManager.sddm.theme = "sddm-astronaut-theme";
                environment.systemPackages = with pkgs; [
                  (
                    sddm-astronaut.override {
                      embeddedTheme = cfg.config.embeddedTheme ? "pixel_sakura";
                    }
                  )
                  kdePackages.qtsvg
                  kdePackages.qtmultimedia
                ];
              }
            )
          ])
        )
        (
          lib.mkIf (cfg.name == "regreet") {
            programs.regreet.enable = lib.mkOverride 900 true;
          }
        )
        (
          lib.mkIf (cfg.name == "plm") {
            # TODO; 26.06 introduces this
            services.displayManager.plasma-login-manager.enable = lib.mkOverride 900 true;
          }
        )
      ];
    };

    # Theming using stylix
    stylix = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.local.displayManager;
    in {
      config = lib.mkMerge [
        (
          lib.mkIf (cfg.name == "gdm") {
            # The nixos option themes gdm, not gnome
            stylix.targets.gnome.enable = true;
          }
        )
        (
          lib.mkIf (cfg.name == "sddm") (let
            flavor = cfg.config.flavor or "mocha";
            accent = cfg.config.accent or "mauve";
          in {
            # There is no stylix target for SDDM, but we can do the cattpuccin theme
            services.displayManager.sddm.theme = "catppuccin-${flavor}-${accent}";
            # Add the desired theme with overrides into the userspace
            environment.systemPackages = [
              (
                pkgs.catppuccin-sddm.override {
                  inherit flavor accent;
                  font = config.stylix.fonts.sansSerif.name;
                  fontSize = toString config.stylix.fonts.sizes.desktop;
                  background = config.stylix.image;
                  loginBackground = cfg.config.loginBackground or true;
                  userIcon = cfg.config.userIcon or true;
                  clockEnabled = cfg.config.clockEnabled or true;
                }
              )
            ];
          })
        )
        (
          lib.mkIf (cfg.name == "regreet") {
            stylix.targets.regreet = {
              enable = true;
              colors.enable = true;
              cursor.enable = true;
              fonts.enable = true;
              icons.enable = true;
              image.enable = true;
              imageScalingMode.enable = true;
            };
          }
        )
        (
          lib.mkIf (cfg.name == "plm") {
            # Not in stylix yet
          }
        )
      ];
    };
  };
}
