# Configuring firefox for wolframite
{inputs, ...}: {
  # Load our firefox account configuring module to den
  den = {
    aspects.wolframite = {
      homeManager = {
        imports = [
          inputs.self.modules.homeManager.firefox-wolframite
        ];
      };
    };
  };

  # Configure global firefox settings
  flake.modules.homeManager.firefox-wolframite = {
    pkgs,
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        # Configuration for firefox here
        programs.firefox = {
          nativeMessagingHosts = with pkgs; [
            tridactyl-native
          ];
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.firefox = {
            # Darwin doesn't use wrapper, language packs only available in linux
            languagePacks = [
              "en-US"
              "tr"
            ];
            nativeMessagingHosts = with pkgs; [
              gnome-browser-connector
              kdePackages.plasma-browser-integration
              (
                # Pywalfox needs patching
                pywalfox-native.overrideAttrs
                (old: {
                  nativeBuildInputs = (old.nativeBuildInputs or []) ++ [jq];
                  postInstall =
                    (old.postInstall or "")
                    + ''
                      mkdir -p $out/lib/mozilla/native-messaging-hosts

                      jq --arg bin "$out/bin/pywalfox" \
                        '.path = $bin' \
                        "${old.src}/pywalfox/assets/manifest.json" \
                        > "$out/lib/mozilla/native-messaging-hosts/pywalfox.json"
                    '';
                })
              )
            ];
          };
        }
      )
      (
        # Configure with local config here
        lib.optionalAttrs ((options.local or {}) ? firefox) {
          local.firefox = {
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
                    ublock-origin
                    duckduckgo-privacy-essentials
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
