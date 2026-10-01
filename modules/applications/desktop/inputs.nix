# Keyboard input settings for desktop
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    # Host schema; allow declaring uinput kernel module
    schema = {
      host = {
        includes = [
          den.aspects.desktop.policies.uinput-host-dispatch
        ];
        options = {
          desktop = lib.mkOption {
            type = lib.types.submodule {
              options = {
                uinput = lib.mkOption {
                  description = ''
                    Settings for uinput, and enabling related tools.
                    - uinput kernel module enables input emulation
                    - ydotool is wayland interface that uses uinput
                  '';
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Enable uinput kernel module and related tooling.";
                        default = true;
                        type = lib.types.bool;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      # User schema; let user use uinput
      user = {
        includes = [
          den.aspects.desktop.policies.uinput-user-dispatch
        ];
        options = {
          uinput = lib.mkOption {
            description = "Whether to enable this user to use the uinput kernel interface.";
            type = lib.types.bool;
            default = true;
          };
        };
      };
    };

    # Aspect
    aspects.desktop = {
      # Auto include the base module by default
      includes = [
        den.aspects.desktop._.inputs
      ];
      provides.to-users.includes = [
        den.aspects.desktop._.inputs._.to-users
      ];

      # Policies for uinput;
      policies = {
        uinput-host-dispatch = {host, ...}:
          lib.optional
          (host.desktop.enable && host.desktop.uinput.enable)
          (den.lib.policy.include den.aspects.desktop._.uinput);
        uinput-user-dispatch = {
          host,
          user,
          ...
        }:
          lib.optional
          (host.desktop.enable && host.desktop.uinput.enable && user.uinput)
          (den.lib.policy.include den.aspects.desktop._.uinput._.user-setup);
      };

      # Base aspect
      provides.inputs = {
        name = "desktop/inputs";
        provides.to-users = {
          host,
          user,
        }: {
          name = "desktop/inputs(${user.userName}@${host.name})";
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.inputs-karabiner
            ];
          };
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.inputs-fcitx5
              inputs.self.modules.homeManager.inputs-spelling
            ];
          };
          stylix = {
            targets.fcitx5 = {
              enable = true;
              colors.enable = true;
              fonts.enable = true;
            };
          };
        };
      };

      # Uinput setup
      provides.uinput = {
        name = "desktop/uinput";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.uinput-settings
          ];
        };
        # Since conditional; named user-setup not to-user
        provides.user-setup = {
          host,
          user,
        }: {
          name = "desktop/uinput(${user.userName}@${host.name})";
          # Put this user in needed groups in NixOS
          user = {
            lib,
            osConfig,
            ...
          }:
            lib.optionalAttrs (host.class == "nixos") {
              extraGroups =
                [
                  "uinput"
                  "ydotool"
                ]
                |> builtins.filter (
                  n:
                    lib.hasAttrByPath
                    ["users" "groups" n]
                    osConfig
                );
            };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Nixos; uinput module
    nixos.uinput-settings = {...}: {
      key = "uinput-settings#nixos";
      config = {
        # Enabel uinput kernel module
        hardware.uinput.enable = true;
        # Wayland interface
        programs.ydotool = {
          enable = true;
        };
      };
    };

    # Darwin: use karabiner-elements to configure keybinds
    darwin.inputs-karabiner = {...}: {
      key = "inputs-karabiner#darwin";
      config = {
        # TODO: nix-darwin stable has the module broken, do from brew for now
        # services.karabiner-elements = { enable = true; };
        homebrew.casks = [
          "karabiner-elements"
        ];
      };
    };

    # Spelling functionality
    homeManager = {
      inputs-spelling = {pkgs, ...}: {
        key = "inputs-spelling#homeManager";
        config = {
          # Install spellcheckers to userspace
          home.packages = with pkgs; [
            enchant # Spellchecker library that can use nuspell
            nuspell # Spellchecker hunspell alternative that can do agglutinative
          ];

          # Spellchecker; enchant should use nuspell backend
          xdg.configFile."enchant/enchant.ordering" = {
            enable = true;
            text = ''
              # Use nuspell for everything first, then fall back to hunspell
              *:nuspell,hunspell,aspell
            '';
          };
        };
      };

      inputs-fcitx5 = {
        pkgs,
        lib,
        ...
      }: {
        key = "inputs-fcitx5#homeManager";
        # Configure keyboard input method; uses fcitx5
        config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          i18n.inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
              waylandFrontend = true;
              addons = with pkgs; [
                kdePackages.fcitx5-qt
                fcitx5-gtk
              ];
              # Settings
              settings = {
                globalOptions = {
                  Hotkey = {
                    ModifierOnlyKeyTimeout = 250;
                    # Switching logic
                    EnumerateWithTriggerKeys = false;
                    EnumerateSkipFirst = false;
                  };
                  # Activation keys
                  "Hotkey/TriggerKeys"."0" = "Control+Super+space";
                  "Hotkey/EnumerateForwardKeys"."0" = "Super+grave";
                  "Hotkey/EnumerateBackwardKeys"."0" = "Super+asciitilde";
                  "Hotkey/EnumerateGroupForwardKeys"."0" = "Control+Super+grave";
                  "Hotkey/EnumerateGroupBackwardKeys"."0" = "Control+Super+asciitilde";
                  Behavior = {
                    # State management
                    resetStateWhenFocusIn = "No";
                    ShareInputState = "No";
                    PreeditEnabledByDefault = false;
                    # Visibility
                    ShowInputMethodInformation = true;
                    CompactInputMethodInformation = true;
                    ShowFirstInputMethodInformation = true;
                    showInputMethodInformationWhenFocusIn = false;
                    # Passwords
                    AllowInputMethodForPassword = false;
                    ShowPreeditForPassword = false;
                    # Behavior
                    ActiveByDefault = false;
                    OverrideXkbOption = true;
                    PreloadInputMethod = true;
                    AutoSavePeriod = 30;
                  };
                };

                # Additional functionality
                addons = {
                  # Spelling config; default to using enchant
                  spell = {
                    sections = {
                      ProviderOrder."0" = "Enchant";
                      ProviderOrder."1" = "Presage";
                      ProviderOrder."2" = "Custom";
                    };
                  };

                  # Quickphrase config
                  # Ctrl + . opens quickphrase menu, type and space insert emoji
                  quickphrase = {
                    globalSection = {
                      "Choose Modifier" = "None";
                      FallbackSpellLanguage = "en";
                      Spell = true;
                      "Commit Key" = "Return";
                      "Choose Key" = "Digit";
                    };
                    sections = {
                      TriggerKey."0" = "Control+period";
                    };
                  };

                  # Unicode entry
                  unicode = {
                    sections = {
                      TriggerKey."0" = "Control+semicolon";
                      DirectUnicodeMode."0" = "Control+Shift+U";
                    };
                  };
                };
              };
            };
          };

          # Add systemd condition to disable daemon launch on desktop
          systemd.user.services.fcitx5-daemon.Unit.ConditionEnvironment = [
            "!KDE_FULL_SESSION"
          ];
        };
      };
    };
  };
}
