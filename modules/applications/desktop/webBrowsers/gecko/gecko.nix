# Module entry point for configuring profiles for gecko based browsers
{...}: let
  # Browsers to produce outputs for this type
  configuredBrowsers = [
    "firefox"
    "librewolf"
    "floorp"
  ];
  # Both firefox and floorp use the base mkFirefoxModule helper;
  # Librewolf adds settings field for global overrides.
in {
  # Gecko setting module; entry point
  flake.modules.homeManager.gecko-profiles = {
    config,
    options,
    lib,
    ...
  }: {
    key = "gecko-browser#homeManager";
    options = let
      profileType = lib.types.submodule {
        # Let free floating options through
        freeformType = lib.types.attrsOf lib.types.anything;
        # Specific options we add; or want to control
        options = {
          # Default profile specification; we hook assertions to this so explicit
          isDefault = lib.mkOption {
            description = "Whether this profile is the default one or not.";
            default = false;
            type = lib.types.bool;
          };
          # Stylix related settings; per profile granular
          stylix = lib.mkOption {
            description = "Stylix related options to use, if enabled.";
            default = {};
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  description = "Enable stylix theming on this profile";
                  type = lib.types.bool;
                  default = true;
                };
                themeOverride = lib.mkOption {
                  description = "Theme override to manually apply to this profile";
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                };
              };
            };
          };
          # Profile fields that will be merged with global settings
          settings = lib.mkOption {
            description = "Settings for this profile.";
            default = {};
            type = (options.programs.firefox.profiles.type.getSubOptions []).settings.type;
          };
          search = lib.mkOption {
            description = "Search engines for this profile";
            default = {};
            type = lib.types.deferredModule;
          };
          extensions = lib.mkOption {
            description = "Extensions for this profile";
            default = {};
            type = lib.types.deferredModule;
          };
        };
      };
    in {
      gecko = lib.mkOption {
        description = "Declarative profile configuration for gecko-based browsers.";
        default = {};
        type = lib.types.submodule {
          options =
            {
              enable = lib.mkOption {
                description = "Enable the gecko browser config module.";
                default = false;
                type = lib.types.bool;
              };
              configuredBrowsers = lib.mkOption {
                description = "List of browsers the gecko module will configure";
                default = configuredBrowsers;
                type = lib.types.listOf lib.types.str;
                readOnly = true;
              };
              # List of profiles
              profiles = lib.mkOption {
                description = "Profile specific settings";
                type = lib.types.attrsOf profileType;
                default = {};
              };
              # Global override spaces
              settings = lib.mkOption {
                description = "Settings to dispatch to all profiles";
                default = {};
                type = (options.programs.firefox.profiles.type.getSubOptions []).settings.type;
              };
              search = lib.mkOption {
                description = "Search engines to dispatch to all profiles";
                default = {};
                type = lib.types.deferredModule;
              };
              extensions = lib.mkOption {
                description = "Extensions to dispatch to all profiles";
                default = {};
                type = lib.types.deferredModule;
              };
            }
            // (
              lib.genAttrs
              configuredBrowsers
              (
                n:
                  lib.mkOption
                  {
                    description = "Settings to dispatch to all profiles in ${n}.";
                    default = {};
                    type = lib.types.submodule {
                      options = {
                        settings = lib.mkOption {
                          description = "Settings to dispatch to all profiles";
                          default = {};
                          type = (options.programs.firefox.profiles.type.getSubOptions []).settings.type;
                        };
                        search = lib.mkOption {
                          description = "Search engines to dispatch to all profiles";
                          default = {};
                          type = lib.types.deferredModule;
                        };
                        extensions = lib.mkOption {
                          description = "Extensions to dispatch to all profiles";
                          default = {};
                          type = lib.types.deferredModule;
                        };
                      };
                    };
                  }
              )
            );
        };
      };
    };

    # Assertions of validity
    config = lib.mkIf (config.gecko.enable or false) {
      assertions = [
        {
          # Assert existence of one and only one default profile
          assertion =
            (config.gecko.profiles == [])
            || (
              config.gecko.profiles
              |> builtins.attrValues
              |> builtins.filter (p: p.isDefault)
              |> (l: (builtins.length l) == 1)
            );
          message = "Gecko module requires exactly one profile to be the default";
        }
      ];
    };
  };
}
