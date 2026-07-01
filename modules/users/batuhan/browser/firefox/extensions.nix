# Configuring firefox extensions
{...}: {
  localConfig.users.batuhan.firefox.global = {
    # Registering things that need native messaging hosts
    nativeMessagingHosts = {
      pkgs,
      lib,
    }: let
      pywalfox-native-with-manifest = pkgs.pywalfox-native.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [pkgs.jq];

        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            mkdir -p $out/lib/mozilla/native-messaging-hosts

            jq --arg bin "$out/bin/pywalfox" \
              '.path = $bin' \
              "${oldAttrs.src}/pywalfox/assets/manifest.json" \
              > "$out/lib/mozilla/native-messaging-hosts/pywalfox.json"
          '';
      });
    in
      with pkgs;
        [
          tridactyl-native
          # keepassxc Auto-added with home-manager
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          gnome-browser-connector
          kdePackages.plasma-browser-integration
          pywalfox-native-with-manifest
        ];

    # Global extensions
    extensions = {
      force = true;

      packages = {
        pkgs,
        lib,
      }:
        with pkgs.nur.repos.rycee.firefox-addons;
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
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            gnome-shell-integration
            plasma-integration
            pywalfox
          ];
    };
  };
}
