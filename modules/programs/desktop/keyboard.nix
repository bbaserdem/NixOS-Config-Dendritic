# Enabling fcitx5 input method
{...}: {
  flake.modules = {
    # Darwin: use karabiner-elements to configure keybinds
    darwin = {
      keyboard = {...}: {
        services.karabiner-elements = {
          enable = true;
        };
      };
    };

    homeManager = {
      # Add fcitx5 to stylix
      stylix = {...}: {
        stylix.targets.fcitx5 = {
          enable = true;
          colors.enable = true;
          fonts.enable = true;
        };
      };

      keyboard = {
        pkgs,
        lib,
        ...
      }: {
        config = lib.mkMerge [
          {}
          # Configure keyboard input method; uses fcitx5
          (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
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
                      # Activation keys
                      "Hotkey/TriggerKeys"."0" = "Control+Super+space";
                      "Hotkey/EnumerateForwardKeys"."0" = "Super+grave";
                      "Hotkey/EnumerateBackwardKeys"."0" = "Super+asciitilde";
                      "Hotkey/EnumerateGroupForwardKeys"."0" = "Control+Super+grave";
                      "Hotkey/EnumerateGroupBackwardKeys"."0" = "Control+Super+asciitilde";
                      # Switching logic
                      EnumerateWithTriggerKeys = false;
                      EnumerateSkipFirst = false;
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
          })
        ];
      };
    };
  };
}
