# LibreWolf setup in den
{
  inputs,
  flib,
  ...
}: {
  # Hook up librewolf to den
  den = {
    aspects.applications = {
      provides.librewolf = {
        # Just dispatch aspect to the user scope
        provides.to-users = {
          host,
          user,
        }: {
          # Collission protection
          name = "applications/librewolf(${user.userName}@${host.name})";
          # Dispatch the home manager modules
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.librewolf-settings
              inputs.self.modules.homeManager.librewolf-profiles
            ];
          };
          # Establish theming
          stylix = {lib, ...}: {
            targets.librewolf = {
              # Can only enable when profiles are non-empty
              enable = lib.mkOptionDefault false;
              # Need this to set the colors
              colorTheme.enable = true;
              # This breaks some stuff actually
              firefoxGnomeTheme.enable = false;
            };
          };
        };
      };
    };
  };

  # LibreWolf setting module
  flake.modules.homeManager.librewolf-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "librewolf-settings#homeManager";
    config = lib.mkMerge [
      {
        programs.librewolf.enable = true;
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          programs.librewolf.package = pkgs.librewolf;
        }
      )
      (
        # Sometimes the nixpkgs version is broken on darwin
        lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          programs.librewolf.package = pkgs.librewolf;
        }
      )
    ];
  };

  # Modules for declaratively configuring profiles in a more ordered fashion
  # We provide home-manager module for configuring profiles
  flake.modules.homeManager.librewolf-profiles = {
    lib,
    pkgs,
    config,
    options,
    ...
  }: let
    # Pull our configuration from the namespace
    cfg = config.local.librewolf;
    #
  in {
    key = "librewolf-profiles#homeManager";
    # Options that can be configured for librewolf locally
    options = let
      # Types to build the options from
      extensionsType = {profile ? false}:
        lib.types.submodule
        {
          options = {
            force = lib.mkOption {
              type =
                if profile
                then lib.types.nullOr lib.types.bool
                else lib.types.bool;
              default =
                if profile
                then null
                else true;
              description = "Whether to force replace managed extension state.";
            };
            packages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [];
              description = ''
                LibreWolf extension packages, or a function returning them.

                Function form is intended for system-dependent packages:
                  {pkgs, lib, ...}: with pkgs.nur.repos.rycee.firefox-addons; [ ... ]
              '';
            };

            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = {};
              description = "Declarative per-extension settings keyed by extension ID.";
            };

            exhaustivePermissions = lib.mkOption {
              type =
                if profile
                then lib.types.nullOr lib.types.bool
                else lib.types.bool;
              default =
                if profile
                then null
                else false;
            };

            exactPermissions = lib.mkOption {
              type =
                if profile
                then lib.types.nullOr lib.types.bool
                else lib.types.bool;
              default =
                if profile
                then null
                else false;
            };
          };
        };
      containerType = lib.types.submodule ({name, ...}: {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = name;
          };

          id = lib.mkOption {
            type = lib.types.ints.unsigned;
            description = "Unique LibreWolf container ID within the profile.";
          };

          icon = lib.mkOption {
            type = lib.types.str;
            default = "circle";
          };

          color = lib.mkOption {
            type = lib.types.str;
            default = "blue";
          };
        };
      });
      profileType = lib.types.submodule ({...}: {
        freeformType = lib.types.attrsOf lib.types.anything;
        options = {
          id = lib.mkOption {
            type = lib.types.nullOr lib.types.ints.unsigned;
            default = null;
            description = "LibreWolf profile ID. If null, the dispatcher must assign one.";
          };

          isDefault = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };

          stylix = lib.mkOption {
            default = {};
            description = "Stylix related options";
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
                };
                themeOverride = lib.mkOption {
                  type = lib.types.nullOr lib.types.path;
                  default = null;
                };
              };
            };
          };

          settings = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
          };

          search = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
          };

          extensions = lib.mkOption {
            type = extensionsType {profile = true;};
            default = {};
          };

          containers = lib.mkOption {
            type = lib.types.attrsOf containerType;
            default = {};
          };
        };
      });
    in {
      # Local option definition
      local.librewolf = lib.mkOption {
        description = "Declarative LibreWolf configuration";
        default = null;
        type = lib.types.nullOr (lib.types.submodule {
          options = {
            global = {
              # These settings will be distributed to all profiles
              settings = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
              };

              # These engines will be distributed to all profiles
              search = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
              };

              # These extensions will be distributed to all profiles
              extensions = lib.mkOption {
                type = extensionsType {profile = false;};
                default = {};
              };
            };

            profiles = lib.mkOption {
              type = lib.types.attrsOf profileType;
              default = {};
            };
          };
        });
      };
    };

    config = lib.mkIf (cfg != null) (
      let
        # Make a full fledged profile section for a given profile
        mkProfile = index: profileItem: {
          name = profileItem.name;
          value =
            (
              # Strip non-librewolf metadata; and get the full attrset
              builtins.removeAttrs
              profileItem.value
              ["stylix"]
            )
            // {
              # Merge in general overrides

              # Explicitly establish these if not defined
              name = profileItem.value.name or profileItem.name;
              path = profileItem.value.path or profileItem.name;

              # Create enumeration id list; unless overridden
              id =
                if (profileItem.value.id or null) == null
                then index
                else profileItem.value.id;

              # Build profile settings on top of global defaults
              settings =
                lib.recursiveUpdate
                cfg.global.settings
                profileItem.value.settings;
              # Build profile search engine on top of global search engine
              search =
                lib.recursiveUpdate
                cfg.global.search
                profileItem.value.search;
              # Build extensions list for profiles
              extensions =
                (
                  cfg.global.extensions
                  // (
                    lib.filterAttrs
                    (_: v: v != null)
                    profileItem.value.extensions
                  )
                )
                // {
                  packages =
                    cfg.global.extensions.packages
                    ++ profileItem.value.extensions.packages;

                  settings =
                    lib.recursiveUpdate
                    cfg.global.extensions.settings
                    profileItem.value.extensions.settings;
                };
            };
        };
        librewolfProfiles =
          cfg.profiles
          |> lib.attrsToList
          |> lib.imap0 mkProfile
          |> builtins.listToAttrs;

        # Color theme generator function; pulled in from stylix
        base16-lib = pkgs.callPackage inputs.base16.lib {};
        mkLibreWolfColorTheme = palette: {
          title = "Stylix ${palette.description}";
          images.additional_backgrounds = ["./bg-000.svg"];
          # Generate colors from palette
          colors =
            {
              toolbar = "base00";
              toolbar_text = "base05";
              frame = "base01";
              tab_background_text = "base05";
              toolbar_field = "base02";
              toolbar_field_text = "base05";
              tab_line = "base0D";
              popup = "base00";
              popup_text = "base05";
              button_background_active = "base04";
              frame_inactive = "base00";
              icons_attention = "base0D";
              icons = "base05";
              ntp_background = "base00";
              ntp_text = "base05";
              popup_border = "base0D";
              popup_highlight_text = "base05";
              popup_highlight = "base04";
              sidebar_border = "base0D";
              sidebar_highlight_text = "base05";
              sidebar_highlight = "base0D";
              sidebar_text = "base05";
              sidebar = "base00";
              tab_background_separator = "base0D";
              tab_loading = "base05";
              tab_selected = "base00";
              tab_text = "base05";
              toolbar_bottom_separator = "base00";
              toolbar_field_border_focus = "base0D";
              toolbar_field_border = "base00";
              toolbar_field_focus = "base00";
              toolbar_field_highlight_text = "base00";
              toolbar_field_highlight = "base0D";
              toolbar_field_separator = "base0D";
              toolbar_vertical_separator = "base0D";
            }
            |> lib.mapAttrs (_: color: {
              r = palette."${color}-rgb-r";
              g = palette."${color}-rgb-g";
              b = palette."${color}-rgb-b";
            });
        };
      in (
        lib.mkMerge [
          {
            programs.librewolf = {
              # Create profiles from our config
              profiles = librewolfProfiles;
            };
          }
          (
            # Stylix options
            lib.optionalAttrs (options ? stylix) {
              # Dispatch enabled profile names
              stylix.targets.librewolf = let
                profileNames =
                  cfg.profiles
                  |> lib.filterAttrs (_: v: (v.stylix.enable or false))
                  |> lib.attrNames;
              in {
                # Enable stylix profile management for select profiles
                enable = lib.mkOverride 1400 (profileNames != []);
                inherit profileNames;
              };
              # Do theme overrides if requested
              programs.librewolf.profiles =
                lib.mkIf (
                  config.stylix.enable
                  && config.stylix.targets.librewolf.enable
                  && config.stylix.targets.librewolf.inputs.enable
                  && config.stylix.targets.librewolf.colors.enable
                  && config.stylix.targets.librewolf.colorTheme.enable
                ) (
                  cfg.profiles
                  |> lib.filterAttrs (
                    n: v:
                      (v.stylix.enable or false)
                      && (v.stylix.themeOverride != null)
                      && (builtins.elem n config.stylix.targets.librewolf.profileNames)
                  )
                  |> lib.mapAttrs (_: p: {
                    extensions.settings."FirefoxColor@mozilla.com".settings.theme =
                      p.stylix.themeOverride
                      # Pull from base16 the library function for parsing yamlW
                      |> base16-lib.mkSchemeAttrs
                      |> mkLibreWolfColorTheme
                      |> lib.mkOverride 55;
                  })
                );
            }
          )
          (
            # Create launchers for linux for the separate profiles
            lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
              xdg.desktopEntries =
                librewolfProfiles
                |> lib.filterAttrs (_: p: !p.isDefault)
                |> lib.mapAttrs' (
                  key: p: let
                    id = "librewolf-${key}";
                    cmd = pkgs.writeShellScript id ''
                      export MOZ_APP_REMOTINGNAME=${lib.escapeShellArg id}
                      exec ${lib.getExe config.programs.librewolf.finalPackage} \
                        -P ${lib.escapeShellArg p.name} \
                        --name ${lib.escapeShellArg id} \
                        --class ${lib.escapeShellArg id} \
                        "$@"
                    '';
                  in (
                    lib.nameValuePair
                    id
                    {
                      name = "LibreWolf (${flib.capitalize p.name})";
                      genericName = "Web Browser";
                      comment = "Launch LibreWolf with the ${p.name} profile";
                      exec = "${cmd} %U";
                      settings.StartupWMClass = id;
                      icon = "librewolf";
                      terminal = false;
                      startupNotify = true;
                      categories = [
                        "Network"
                        "WebBrowser"
                      ];
                    }
                  )
                );
            }
          )
          (
            # Create launchers for darwin for the separate profiles
            lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
              home.packages =
                librewolfProfiles
                |> lib.filterAttrs (_: p: !p.isDefault)
                |> lib.mapAttrsToList (
                  key: p: let
                    id = "librewolf-${key}";
                    appName = "LibreWolf (${flib.capitalize p.name})";
                    librewolfApp = "${config.programs.librewolf.finalPackage}/Applications/LibreWolf.app";
                  in (
                    pkgs.runCommand "${id}-launcher"
                    {
                      launcher = pkgs.writeShellScript id ''
                        exec /usr/bin/open -n -a ${lib.escapeShellArg librewolfApp} \
                          --args -P ${lib.escapeShellArg p.name} "$@"
                      '';
                      infoPlist = pkgs.writeText "${id}.plist" (
                        lib.generators.toPlist {escape = true;} {
                          CFBundleName = appName;
                          CFBundleDisplayName = appName;
                          CFBundleIdentifier = "local.librewolf-profile.${key}";
                          CFBundlePackageType = "APPL";
                          CFBundleExecutable = "launcher";
                          CFBundleIconFile = "firefox.icns";
                          CFBundleVersion = "1.0";

                          # The launcher itself does not need a running Dock icon.
                          LSUIElement = true;
                        }
                      );
                    }
                    ''
                      app="$out/Applications"/${lib.escapeShellArg "${appName}.app"}

                      mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"

                      install -m755 "$launcher" "$app/Contents/MacOS/launcher"
                      cp "$infoPlist" "$app/Contents/Info.plist"
                      cp ${lib.escapeShellArg "${librewolfApp}/Contents/Resources/firefox.icns"} \
                        "$app/Contents/Resources/firefox.icns"
                    ''
                  )
                );
            }
          )
        ]
      )
    );
  };
}
