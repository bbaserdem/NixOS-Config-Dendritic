# Keyboard config for wolframite
{...}: {
  flake.modules.homeManager.wolframite-keymap = {
    lib,
    options,
    ...
  }: {
    key = "wolframite-keymap#homeManager";
    config = lib.mkMerge [
      ( # Mango; base keybinds should use dvorak
        lib.optionalAttrs
        (lib.hasAttrByPath ["wayland" "windowManager" "mango"] options)
        {
          # The xkb settings should use dvorak
          wayland.windowManager.mango.settings. xkb.rules = {
            layout = "us";
            variant = "dvorak-alt-intl";
          };
        }
      )
      {
        # Keyboard input settings

        # Set up fcitx5 for my input methods
        i18n.inputMethod.fcitx5 = {
          # Quickphrases
          quickPhrase = {
            # Emojis
            ":evilsmirk:" = "😈";
          };
          # Language input setup
          # Default uses english dvorak, switches to qwerty
          # Turkish uses f, switches to qwerty
          settings = {
            inputMethod = {
              GroupOrder = {
                "0" = "English";
                "1" = "Turkish";
              };
              # English language group
              "Groups/0" = {
                Name = "English";
                # For window manager
                "Default Layout" = "us-dvorak-alt-intl";
                # Default layout
                DefaultIM = "keyboard-us-alt-intl";
              };
              "Groups/0/Items/0".Name = "keyboard-us-dvorak-alt-intl";
              "Groups/0/Items/1".Name = "keyboard-us-alt-intl";
              # Turkish language group
              "Groups/1" = {
                Name = "Turkish";
                # For window manager
                "Default Layout" = "us-dvorak-alt-intl";
                # Default layout
                DefaultIM = "keyboard-tr-f";
              };
              "Groups/1/Items/0".Name = "keyboard-us-dvorak-alt-intl";
              "Groups/1/Items/1".Name = "keyboard-tr-f";
              "Groups/1/Items/2".Name = "keyboard-tr-intl";
            };
          };
        };

        # Configure XKB fallback
        home = {
          # Set layout
          keyboard = {
            layout = "us,tr,us";
            variant = "dvorak-alt-intl,f,altgr-intl";
            options = ["grp:alt_caps_toggle"];
          };

          # Set locale
          language = {
            base = "en_US.UTF-8";
            name = "tr_TR.UTF-8";
          };
        };

        # Configure GNOME fallback
        dconf.settings = {
          # Keyboard layout set here specifically for gnome
          "org/gnome/desktop/input-sources" = {
            mru-sources = [
              (lib.hm.gvariant.mkTuple ["xkb" "us+dvorak-alt-intl"])
              (lib.hm.gvariant.mkTuple ["xkb" "tr+f"])
              (lib.hm.gvariant.mkTuple ["xkb" "us+altgr-intl"])
            ];
            per-window = false;
            show-all-sources = true;
            sources = [
              (lib.hm.gvariant.mkTuple ["xkb" "us+dvorak-alt-intl"])
              (lib.hm.gvariant.mkTuple ["xkb" "tr+f"])
              (lib.hm.gvariant.mkTuple ["xkb" "us+altgr-intl"])
            ];
            xkb-options = [
              "compose:ins"
              "grp:alt_caps_toggle"
            ];
          };
        };
      }
    ];
  };
}
