# Keyboard input settings for desktop
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.desktop = {
      # Auto include us
      includes = [
        den.aspects.desktop._.inputs
      ];
      # Our aspect
      provides.inputs = {
        provides.to-user = {
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
                |> builtins.filter (n: lib.hasAttrByPath ["users" "groups" n] osConfig);
            };
        };
      };
    };
  };

  # Modules
  flake.modules = {
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
    homeManager.inputs-spelling = {pkgs, ...}: {
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

    homeManager.inputs-fcitx5 = {
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
}
