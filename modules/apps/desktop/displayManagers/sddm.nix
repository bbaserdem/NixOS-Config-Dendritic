# SDDM configuration
{...}: {
  flake.modules = {
    nixos = {
      sddm = {
        lib,
        pkgs,
        options,
        ...
      }: {
        # Application of the selected options
        config = lib.mkMerge [
          {
            # Set us as the display manager
            local.displayManager = "sddm";
            # Configure sddm, besides the activation
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
                (sddm-astronaut.override {embeddedTheme = "pixel_sakura";})
                kdePackages.qtsvg
                kdePackages.qtmultimedia
              ];
            }
          )
        ];
      };

      # Stylix based theming for SDDM
      stylix = {
        lib,
        config,
        pkgs,
        ...
      }: {
        config = lib.mkIf (config.local.displayManager == "sddm") (let
          flavor = "mocha";
          accent = "mauve";
        in {
          # There is no stylix target for SDDM, but we can do the cattpuccin theme
          services.displayManager.sddm.theme = "catppuccin-${flavor}-${accent}";
          # Add the desired theme with overrides into the userspace
          environment.systemPackages = [
            (
              pkgs.catppuccin-sddm.override {
                inherit flavor accent;
                font = config.stylix.fonts.sansSerif.name;
                fontSize = config.stylix.fonts.sizes.desktop;
                background = config.stylix.image;
                loginBackground = true;
                userIcon = true;
                clockEnabled = true;
              }
            )
          ];
        });
      };
    };
  };
}
