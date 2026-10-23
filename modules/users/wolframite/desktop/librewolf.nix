# Configuring librewolf specific settings
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
      ( # Linux only settings
        lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          programs.librewolf = {
            settings = {
              # Use geoclue as location provider
              "geo.provider.use_geoclue" = true;
            };
          };
        }
      )
      ( # Module settings
        lib.optionalAttrs (options ? gecko) {
          gecko.librewolf = {
            search.engines = {
              # Perplexity search
              perplexity = {
                name = "Perplexity";
                urls = [
                  {
                    template = "https://www.perplexity.ai/search";
                    params = [
                      {
                        name = "q";
                        value = "{searchTerms}";
                      }
                    ];
                  }
                ];
                icon = "https://www.perplexity.ai/favicon.ico";
                definedAliases = ["@p"];
              };
            };
          };
        }
      )
      {
        # Configuration for librewolf here
        programs.librewolf = {
          # Some common shared settings
          settings = {
            # Enable mozilla sync
            "identity.fxaccounts.enabled" = true;
            # DRM enable
            "media.eme.enabled" = true;
            "media.gmp-manager.updateEnabled" = true;
            "media.gmp-widevinecdm.enabled" = true;
            "media.gmp-widevinecdm.autoupdate" = true;
            # Replace RFP with FPP in regular browsing
            "privacy.resistFingerprinting" = false;
            "privacy.resistFingerprinting.pbmode" = true;
            "privacy.fingerprintingProtection" = true;
            "privacy.fingerprintingProtection.pbmode" = false;
            "privacy.fingerprintingProtection.overrides" =
              "+AllTargets"
              + ",-CSSPrefersColorScheme"
              + ",-JSDateTimeUTC";
            # Relaxing clean on shutdown settings to be less aggressive
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
            "privacy.clearOnShutdown.cookies" = false;
            "privacy.clearOnShutdown.sessions" = false;
            # Default to system theme for dark/light mode
            "layout.css.prefers-color-scheme.content-override" = 2;
            # System integration
            "widget.use-xdg-desktop-portal.file-picker" = 1;
          };
          # Policy settings
          policies = {
            # Firefox sync; we only want history sync;
            Sync = {
              History = true;
              Passwords = false;
              Addresses = false;
              PaymentMethods = false;
            };
            # Lock the DRM policy
            EncryptedMediaExtensions.Locked = true;

            # Block notification request windows
            Permissions.Notifications = {
              BlockNewRequests = true;
              Locked = true;
            };

            Preferences = {
              # Auto-enable nix installed extensions
              "extensions.autoDisableScopes" = {
                Value = 0;
                Status = "locked";
              };
              # Disable accessibility features
              "accessibility.force_disabled" = {
                Value = 1;
                Status = "locked";
              };
              # Disable desktop notification feature
              "permissions.default.desktop-notification" = {
                Value = 2;
                Status = "locked";
              };
            };
          };
        };
      }
    ];
  };
}
