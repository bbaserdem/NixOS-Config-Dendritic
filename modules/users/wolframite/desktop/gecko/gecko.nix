# Configuring profiles for firefox derivatives
{...}: {
  flake.modules.homeManager.wolframite-gecko = {
    pkgs,
    lib,
    options,
    ...
  }: {
    key = "wolframite-gecko#homeManager";
    config = lib.mkMerge [
      (
        # Configure
        lib.optionalAttrs (options ? gecko) {
          gecko = {
            # Enable profile management
            enable = true;

            # Different profiles
            profiles = {
              personal = {
                isDefault = true;
                containersForce = true;
              };

              work = {
                stylix.themeOverride = "${pkgs.base16-schemes}/share/themes/apathy.yaml";
                containersForce = true;
              };

              explicit = {
                stylix.themeOverride = "${pkgs.base16-schemes}/share/themes/caroline.yaml";
                containersForce = true;
              };
            };

            # Global extensions
            extensions = {
              force = true;
              packages = with pkgs.nur.repos.rycee.firefox-addons; ([
                  # UI
                  behind-the-overlay-revival
                  don-t-fuck-with-paste
                  # Containers
                  multi-account-containers
                  containerise
                  # Privacy
                  mullvad
                  # Passwords
                  keepassxc-browser
                  # Downloader
                  aria2-integration
                ]
                ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
                  # Desktop integration extensions
                  pywalfox
                  gnome-shell-integration
                  plasma-integration
                ]));
            };
          };
        }
      )
      {
        # Configure non-profile related global config options
        programs =
          lib.genAttrs
          ["firefox" "librewolf"]
          (_n: {
            # Add tridactyl
            nativeMessagingHosts = with pkgs; (
              [
                tridactyl-native
              ]
              ++ (lib.optionals pkgs.stdenv.hostPlatform.isLinux [
                pywalfox-native
              ])
            );

            policies = {
              # Set firefox sync global settings
              Sync = {
                Enabled = true;
                Locked = true;

                # TODO: find external local bookmark solution
                Bookmarks = true;
                OpenTabs = false;
                Addons = false;
                Settings = false;
              };

              # Disabling telemetry
              DisableTelemetry = true;
              DisableFirefoxStudies = true;

              # Needed for DRM
              EncryptedMediaExtensions = {
                Enabled = true;
              };

              # Block every ai feature
              AIControls = let
                _blocked = {
                  Value = "blocked";
                  Locked = true;
                };
              in {
                Default = _blocked;
                Translations = _blocked;
                PDFAltText = _blocked;
                SmartTabGroups = _blocked;
                LinkPreviewKeyPoints = _blocked;
                SidebarChatbot = _blocked;
                SmartWindow = _blocked;
              };
            };
          });
      }
    ];
  };
}
