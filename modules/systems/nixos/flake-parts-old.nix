# TODO: Delete after den migration
{inputs, ...}: {
  # Stylix theming of grub?
  flake.modules.nixos.stylix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.local.displayManager;
  in {
    config = lib.mkMerge [
      {
        stylix.targets = {
          grub = {
            enable = true;
            useWallpaper = true;
          };
          console = {
            enable = true;
            colors.enable = true;
          };
        };
      }
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

  # nixos.nix
  flake.modules.nixos.nixos = {...}: {
    # Base imports; all nixos invocations should have these
    imports = with inputs.self.modules.nixos; [
      nix
      homeManager
      shell
      # Sub-module imports as well
      nixos-bootloader
      nixos-boot-local
      nixos-boot-grub-old
      nixos-boot-systemd-old
      nixos-console-old
      nixos-displayManager
      nixos-displayManager-local
      nixos-displayManager-gdm
      nixos-displayManager-plm
      nixos-displayManager-sddm
      nixos-displayManager-regreet
      nixos-filesystem
      inputs.self.modules.generic.os-filesystem
      inputs.disko.nixosModules.disko
      nixos-hardware
      nixos-keyboard
      nixos-locale
      nixos-networking
      nixos-root
      nixos-accounts
    ];
  };

  # boot.nix
  flake.modules.nixos.nixos-boot-local = {lib, ...}: {
    # Allow hosts to determine the bootloader to use
    options = {
      local.boot = {
        loader = lib.mkOption {
          type = lib.types.enum [
            "systemd-boot"
            "grub"
          ];
          default = "grub";
          description = "Bootloader backend to enable for the NixOS host.";
        };
        grub = {
          stylix = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to use stylix to theme grub";
          };
          flavor = lib.mkOption {
            type = lib.types.enum [
              "orange"
              "white"
              "dark"
              "bigSur"
            ];
            default = "dark";
            description = "Grub theme variant to use outside stylix";
          };
        };
      };
    };
  };

  flake.modules.nixos.nixos-boot-grub-old = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    configurationLimit = 10;
  in {
    config = lib.mkIf (config.local.boot.loader == "grub") (
      lib.mkMerge [
        {
          # Grub settings
          boot.loader.grub = {
            inherit configurationLimit;
            enable = true;
            efiSupport = true;
            useOSProber = true;
            memtest86.enable = true;
            devices = ["nodev"];
          };
        }
        (
          # If stylix is overriden, or unavailable, use sleek-grub-theme
          lib.mkIf (!(
            (config.local.boot.grub.stylix)
            && (lib.hasAttrByPath ["stylix"] options)
          )) {
            boot.loader.grub.theme = pkgs.sleek-grub-theme.override {
              withStyle = config.local.boot.grub.flavor;
            };
          }
        )
      ]
    );
  };

  flake.modules.nixos.nixos-boot-systemd-old = {
    config,
    lib,
    ...
  }: let
    configurationLimit = 10;
  in {
    config = lib.mkIf (config.local.boot.loader == "systemd-boot") {
      # Systemd-boot settings
      # Not used, but can switch to in the future
      boot.loader.systemd-boot = {
        enable = true;
        inherit configurationLimit;
        edk2-uefi-shell = {
          enable = true;
          sortKey = "y_edk2-uefi-shell";
        };
        memtest86 = {
          enable = true;
          sortKey = "z_memtest86";
        };
        netbootxyz = {
          enable = true;
          sortKey = "x_netbookxyz";
        };
      };
    };
  };

  # Console.nix
  flake.modules.nixos.nixos-console-old = {pkgs, ...}: {
    key = "nixos-console-old#nixos";
    config = {
      console = {
        earlySetup = true;
        # Set console font
        font = "ter-powerline-v24b";
        packages = with pkgs; [
          terminus_font
          powerline-fonts
        ];
        # Set keymap of console
        keyMap = "dvorak";
      };
    };
  };

  # displayManager.nix
  flake.modules.nixos.nixos-displayManager = {lib, ...}: {
    # Application of the selected options
    services.displayManager.gdm.enable = lib.mkOverride 950 false;
    services.displayManager.sddm.enable = lib.mkOverride 950 false;
    programs.regreet.enable = lib.mkOverride 950 false;
    services.displayManager.plasma-login-manager.enable = lib.mkOverride 950 false;
  };
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
                embeddedTheme = cfg.config.embeddedTheme or "pixel_sakura";
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

  # keyboard.nix
  flake.modules.nixos.nixos-keyboard = {...}: {
    config = {
      # Default my systems to dvorak
      services.xserver.xkb = {
        layout = "us,tr,us";
        variant = "dvorak-alt-intl,f,altgr-intl";
        options = "grp:alt_caps_toggle";
      };

      # Enable uinput; kernel interface for synthesizing inputs
      hardware.uinput.enable = true;
    };
  };

  # locale.nix
  flake.modules.nixos.nixos-locale = {...}: {
    i18n = {
      defaultCharset = "UTF-8";
      defaultLocale = "en_US.UTF-8";
      extraLocales = [
        "C.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "en_DK.UTF-8/UTF-8"
        "tr_TR.UTF-8/UTF-8"
      ];
      extraLocaleSettings = {
        # System language
        LANGUAGE = "en_US";
        LC_MESSAGES = "en_US.UTF-8";

        # Time and units
        LC_TIME = "en_DK.UTF-8";
        LC_MEASUREMENT = "en_DK.UTF-8";

        # Dev tooling behavior
        LC_NUMERIC = "en_US.UTF-8";
        LC_COLLATE = "C.UTF-8";
        LC_CTYPE = "en_US.UTF-8";

        # Other stuff
        LC_ADDRESS = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
      };
    };
  };
}
