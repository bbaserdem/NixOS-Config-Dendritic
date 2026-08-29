# Display manager setup for nixos systems
{
  lib,
  den,
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
      includes = [
        den.aspects.system._.displayManager.policies.nixos-displayManager-dispatch
      ];

      # Display manager policies
      provides.displayManager = {
        policies.nixos-displayManager-dispatch = {host, ...}:
          if
            (
              (host.class == "nixos")
              && (host.displayManager != null)
              && (host.displayManager.name != null)
            )
          then [
            (den.lib.policy.include den.aspects.system._.displayManager._.${host.displayManager.name})
          ]
          else [];

        provides.gdm = {host}: {
          nixos = {lib, ...}: {
            services.displayManager.gdm.enable = lib.mkOverride 900 (host.displayManager.name == "gdm");
          };
          # Enable stylix theming too
          stylix = {
            targets.gnome.enable = true;
          };
        };

        provides.sddm = {host}: {
          nixos = {
            lib,
            pkgs,
            config,
            options,
            ...
          }: {
            config = lib.mkMerge [
              {
                services.displayManager.sddm.enable = lib.mkOverride 900 (host.displayManager.name == "sddm");
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
                lib.optionalAttrs (options ? stylix) (
                  # Theming done here; no stylix theming yet we do cattpuccin
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

        provides.plm = {host}: {
          nixos = {lib, ...}: {
            services.displayManager.plasma-login-manager.enable =
              lib.mkOverride 900 (host.displayManager.name == "plm");
          };
        };

        provides.regreet = {host}: {
          nixos = {lib, ...}: {
            programs.regreet.enable = lib.mkOverride 900 (host.displayManager.name == "regreet");
          };
          # Stylix theming too
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

  flake.modules.nixos.nixos-displayManager = {lib, ...}: {
    # Application of the selected options
    services.displayManager.gdm.enable = lib.mkOverride 950 false;
    services.displayManager.sddm.enable = lib.mkOverride 950 false;
    programs.regreet.enable = lib.mkOverride 950 false;
    services.displayManager.plasma-login-manager.enable = lib.mkOverride 950 false;
  };

  # TODO: Remove these after den migration
  flake.modules.nixos.nixos-displayManager-local = {lib, ...}: {
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
  };

  flake.modules.nixos.nixos-displayManager-gdm = {
    lib,
    config,
    ...
  }: let
    cfg = config.local.displayManager;
  in {
    config = lib.mkIf (cfg.name == "gdm") {
      services.displayManager.gdm.enable = lib.mkOverride 900 true;
    };
  };

  flake.modules.nixos.nixos-displayManager-sddm = {
    lib,
    config,
    pkgs,
    options,
    ...
  }: let
    cfg = config.local.displayManager;
  in {
    config = lib.mkIf (cfg.name == "sddm") (lib.mkMerge [
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
    ]);
  };

  flake.modules.nixos.nixos-displayManager-plm = {
    lib,
    config,
    ...
  }: let
    cfg = config.local.displayManager;
  in {
    config = lib.mkIf (cfg.name == "plm") {
      services.displayManager.plasma-login-manager.enable = lib.mkOverride 900 true;
    };
  };

  flake.modules.nixos.nixos-displayManager-regreet = {
    lib,
    config,
    ...
  }: let
    cfg = config.local.displayManager;
  in {
    config = lib.mkIf (cfg.name == "regreet") {
      programs.regreet.enable = lib.mkOverride 900 true;
    };
  };

  # Theming using stylix
  flake.modules.nixos.stylix = {
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
}
