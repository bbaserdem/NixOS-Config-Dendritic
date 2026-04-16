# Keyboard config for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
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
          "Groups/0" = {
            Name = "English";
            "Default Layout" = "us-dvorak-alt-intl";
            DefaultIM = "keyboard-us-alt-intl";
          };
          "Groups/0/Items/0".Name = "keyboard-us-dvorak-alt-intl";
          "Groups/0/Items/1".Name = "keyboard-us-alt-intl";
          "Groups/1" = {
            Name = "Turkish";
            "Default Layout" = "tr-f";
            DefaultIM = "keyboard-tr-intl";
          };
          "Groups/1/Items/0".Name = "keyboard-tr-f";
          "Groups/1/Items/1".Name = "keyboard-tr-intl";
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
        collate = "tr_TR.UTF-8";
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
  };
}
