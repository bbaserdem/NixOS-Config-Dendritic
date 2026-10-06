# Configuring librewolf for wolframite
{...}: {
  # Configure global librewolf settings
  flake.modules.homeManager.wolframite-librewolf = {
    pkgs,
    lib,
    options,
    ...
  }: {
    key = "wolframite-librewolf#homeManager";
    config = lib.mkMerge [
      {
        # Configuration for librewolf here
        programs.librewolf = {
          # Some common shared settings
          settings = {
            # Enable mozilla sync
            "identity.fxaccounts.enabled" = true;
            # DRM enable
            "media.gmp-manager.updateEnabled" = true;
            "media.gmp-widevinecdm.enabled" = true;
            "media.gmp-widevinecdm.autoupdate" = true;
          };
          nativeMessagingHosts = with pkgs; [
            tridactyl-native
          ];
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.librewolf = {
            # Darwin doesn't use wrapper, language packs only available in linux
            # Needs patched; but fetcher gets unpatched; can't use this
            # languagePacks = [ "en-US" "tr" ];
            nativeMessagingHosts = with pkgs; [
              gnome-browser-connector
              kdePackages.plasma-browser-integration
              pywalfox-native
            ];
          };
        }
      )
      (
        # Configure with local config here
        lib.optionalAttrs ((options.local or {}) ? librewolf) {
          local.librewolf = {
            # Different profiles
            profiles = {
              personal = {
                id = 0;
                isDefault = true;
                containersForce = true;
              };

              work = {
                id = 1;
                containersForce = true;
                stylix.themeOverride = "${pkgs.base16-schemes}/share/themes/digital-rain.yaml";
              };

              explicit = {
                id = 2;
                containersForce = true;
                stylix.themeOverride = "${pkgs.base16-schemes}/share/themes/caroline.yaml";
              };
            };

            # Global settings
            global = {
              # Global extensions
              extensions = {
                force = true;
                packages = with pkgs.nur.repos.rycee.firefox-addons; (
                  [
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
                    gnome-shell-integration
                    plasma-integration
                    pywalfox
                  ])
                );
              };
            };
          };
        }
      )
    ];
  };
}
