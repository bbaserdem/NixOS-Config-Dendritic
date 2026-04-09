# Configuring firefox plugins for batuhan
{...}: {
  flake.modules.homeManager.batuhan = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        programs.firefox = {
          # Native messaging hosts
          nativeMessagingHosts = with pkgs; [
            tridactyl-native
            keepassxc
          ];
          # Need to include native messaging hosts as a package overlay
          profiles.batuhan = {
            isDefault = true;
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              # Steam store helpers
              augmented-steam
              protondb-for-steam
              steam-database
              # Graphical candy
              automatic-dark
              behind-the-overlay-revival
              catppuccin-web-file-icons
              enhanced-github
              gruvbox-dark-theme
              # Bandcamp
              batchcamp
              # Twitch
              betterttv
              # Casting
              castkodi
              # Containers
              containerise
              multi-account-containers
              open-url-in-container
              # Quality of Life
              duckduckgo-privacy-essentials
              don-t-fuck-with-paste
              flagfox
              h264ify
              private-grammar-checker-harper
              # OS integration
              gnome-shell-integration
              plasma-integration
              # Synching
              keepassxc-browser
              # VPN
              mullvad
              # Functionality
              greasemonkey
              user-agent-string-switcher
              # Adblock
              sponsorblock
              ublock-origin
              # Downloaders
              video-downloadhelper
              aria2-integration
              # Zotero
              zotero-connector
            ];
          };
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) (let
          # Pywalfox doesn't have manifest by default, override it
          pywalfox-native-with-manifest = pkgs.pywalfox-native.overrideAttrs (oldAttrs: {
            nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.jq];
            postInstall =
              (oldAttrs.postInstall or "")
              + ''
                # Generate the native messaging manifest for Firefox
                mkdir -p $out/lib/mozilla/native-messaging-hosts

                # Creating the manifest JSON so native-messaging-hosts is installed properly
                # It only runs imperatively, hardcoded to output to specific paths
                # Parses the asset's path variable which is set to <path>
                # We use jq to read the source manifest, update 'path', and save to the output
                jq --arg bin "$out/bin/pywalfox" \
                  '.path = $bin' \
                  "${oldAttrs.src}/pywalfox/assets/manifest.json" \
                  > "$out/lib/mozilla/native-messaging-hosts/pywalfox.json
              '';
          });
        in {
          programs.firefox = {
            nativeMessagingHosts = with pkgs; [
              vdhcoapp
              gnome-browser-connector
              kdePackages.plasma-browser-integration
              pywalfox-native-with-manifest
            ];
          };
          # Install these packages to userspace
          home.packages = with pkgs; [
            vdhcoapp
            pywalfox-native-with-manifest
          ];
        })
      )
    ];
  };
}
