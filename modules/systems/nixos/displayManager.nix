# Display manager setup for nixos systems
{
  lib,
  den,
  inputs,
  ...
}: {
  # Den options
  den = {
    schema.host = {config, ...}: {
      options = {
        displayManager = lib.mkOption {
          description = "Display manager info (NixOS only)";
          default =
            if config.class == "nixos"
            then {}
            else null;
          apply = value:
            if config.class == "nixos"
            then value
            else if (value != null)
            then
              throw ''
                Host ${config.name}'s displayManager must be null if not "nixos"
                ${config.name}.class is currently `${config.class}`
              ''
            else null;
          type = lib.types.nullOr (
            lib.types.submodule ({...}: {
              options = {
                name = lib.mkOption {
                  description = "Display manager to be used by nixos.";
                  default = null;
                  type = lib.types.nullOr (lib.types.enum [
                    "gdm"
                    "sddm"
                    "regreet"
                    "plm"
                  ]);
                };
                config = lib.mkOption {
                  description = "Options to pass on to the display manager.";
                  default = {};
                  type = lib.types.attrs;
                };
              };
            })
          );
        };
      };
    };

    aspects.system = {
      provides.nixos = {
        # Base aspect; and type dispatch policy
        includes = [
          den.aspects.system._.nixos.policies.nixos-dm-dispatch
        ];
        # Policy that enables the dispatch of display managers
        policies.nixos-dm-dispatch = {host, ...}:
          lib.optionals
          (
            (host.class == "nixos")
            && (host.displayManager != null)
            && (host.displayManager.name != null)
          )
          [
            (
              den.lib.policy.include
              den.aspects.system._.nixos._.dm
            )
            (
              den.lib.policy.include
              den.aspects.system._.nixos._.dm._.${host.displayManager.name}
            )
          ];

        # Display manager aspects
        provides.dm = {
          name = "system/nixos/dm";
          # Base aspect to disable all by default
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-dm
            ];
          };
          # Gnome display manager
          provides.gdm = {host}: {
            name = "system/nixos/dm/gdm(@${host.name})";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-gdm
              ];
            };
            # Enable stylix for gdm
            stylix = {
              targets.gnome.enable = true;
            };
          };
          # Simple desktop display manager
          provides.sddm = {host}: {
            name = "system/nixos/dm/sddm(@${host.name})";
            nixos = {
              lib,
              pkgs,
              config,
              options,
              ...
            }: {
              imports = [
                inputs.self.modules.nixos.nixos-sddm
              ];
              # Theming config
              config = lib.mkMerge [
                (
                  lib.optionalAttrs (options ? stylix) (
                    # Theming done here, not in stylix; no stylix theme yet!
                    let
                      flavor = host.displayManager.config.flavor or "mocha";
                      accent = host.displayManager.config.accent or "mauve";
                    in {
                      services.displayManager.sddm.theme = "catppuccin-${flavor}-${accent}";
                      # Add the desired theme with overrides into the userspace
                      environment.systemPackages = [
                        (
                          pkgs.catppuccin-sddm.override {
                            inherit flavor accent;
                            font = config.stylix.fonts.sansSerif.name;
                            fontSize = toString config.stylix.fonts.sizes.desktop;
                            background = config.stylix.image;
                            loginBackground = host.displayManager.config.loginBackground or true;
                            userIcon = host.displayManager.config.userIcon or true;
                            clockEnabled = host.displayManager.config.clockEnabled or true;
                          }
                        )
                      ];
                    }
                  )
                )
                (
                  # Fallback theme if stylix is not available
                  lib.optionalAttrs (! (options ? stylix)) {
                    services.displayManager.sddm.theme = "sddm-astronaut-theme";
                    environment.systemPackages = with pkgs; [
                      (
                        sddm-astronaut.override {
                          embeddedTheme = host.displayManager.config.embeddedTheme or "pixel_sakura";
                        }
                      )
                      kdePackages.qtsvg
                      kdePackages.qtmultimedia
                    ];
                  }
                )
              ];
            };
          };
          # Plasma login manager
          provides.plm = {host}: {
            name = "system/nixos/dm/plm(@${host.name})";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-plm
              ];
            };
          };
          # Regreet uses greetd
          provides.regreet = {host}: {
            name = "system/nixos/dm/regreet(@${host.name})";
            nixos = {...}: {
              imports = [
                inputs.self.modules.nixos.nixos-regreet
              ];
            };
            # Stylix theming
            stylix = {
              targets.regreet = {
                enable = true;
                colors.enable = true;
                cursor.enable = true;
                fonts.enable = true;
                icons.enable = true;
                image.enable = true;
                imageScalingMode.enable = true;
              };
            };
          };
        };
      };
    };
  };

  # Modules
  flake.modules.nixos = {
    nixos-dm = {lib, ...}: {
      key = "nixos-dm#nixos";
      config = {
        # Application of the selected options
        services.displayManager.gdm.enable = lib.mkOverride 950 false;
        services.displayManager.sddm.enable = lib.mkOverride 950 false;
        programs.regreet.enable = lib.mkOverride 950 false;
        services.displayManager.plasma-login-manager.enable = lib.mkOverride 950 false;
      };
    };
    nixos-gdm = {lib, ...}: {
      key = "nixos-gdm#nixos";
      config = {
        services.displayManager.gdm = {
          enable = lib.mkOverride 900 true;
        };
      };
    };
    nixos-sddm = {
      lib,
      pkgs,
      ...
    }: {
      key = "nixos-sddm#nixos";
      config = {
        services.displayManager.sddm = {
          enable = lib.mkOverride 900 true;
          enableHidpi = true;
          wayland.enable = true;
          settings.General.InputMethod = "qtvirtualkeyboard";
        };
        environment.systemPackages = with pkgs; [
          kdePackages.qtvirtualkeyboard
        ];
      };
    };
    nixos-plm = {lib, ...}: {
      key = "nixos-plm#nixos";
      config = {
        services.displayManager.plasma-login-manager = {
          enable = lib.mkOverride 900 true;
        };
      };
    };
    nixos-regreet = {lib, ...}: {
      key = "nixos-regreet#nixos";
      config = {
        programs.regreet = {
          enable = lib.mkOverride 900 true;
        };
      };
    };
  };
}
