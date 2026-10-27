# Extra launchers for non-default profiles
{
  inputs,
  flib,
  ...
}: let
  prettyNames = {
    firefox = "Firefox";
    librewolf = "LibreWolf";
    floorp = "Floorp";
  };
in {
  flake.modules.homeManager.gecko-profiles = {
    config,
    pkgs,
    options,
    lib,
    ...
  }: {
    key = "gecko-profiles/launcher#homeManager";
    config = lib.mkIf (config.gecko.enable or false) (let
      base16-lib = pkgs.callPackage inputs.base16.lib {};
      nonDefaultProfiles =
        config.gecko.profiles
        |> lib.filterAttrs (_: p: !p.isDefault);
      # Icon overrides in linux; if stylix is available and appropriate for the profile
      iconOverrides =
        nonDefaultProfiles
        |> lib.filterAttrs (
          _: p: (
            p.stylix.enable
            && (p.stylix.themeOverride != null)
            && (options ? stylix)
          )
        )
        |> lib.mapAttrs (
          name: profile: (
            let
              palette = base16-lib.mkSchemeAttrs profile.stylix.themeOverride;
            in (browser: "${
              pkgs.runCommandLocal
              "${browser}-${name}-icon.png"
              {nativeBuildInputs = [pkgs.imagemagick];}
              ''
                magick \
                  ${config.programs.${browser}.finalPackage}/share/icons/hicolor/128x128/apps/${browser}.png \
                  -colorspace gray \
                  -channel RGB \
                  +level-colors ${lib.escapeShellArg "#${palette.base00},#${palette.base05}"} \
                  +channel \
                  "$out"
              ''
            }")
          )
        );
    in (
      lib.mkMerge [
        # Linux; create xdg launchers
        (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          xdg.desktopEntries = lib.mkMerge (
            config.gecko.configuredBrowsers
            |> builtins.map (
              browser:
                lib.mkIf
                config.programs.${browser}.enable
                (
                  nonDefaultProfiles
                  |> lib.mapAttrs' (
                    name: profile: let
                      id = "${browser}-${name}";
                      prettyName = prettyNames.${browser};
                      cmd = pkgs.writeShellScript id ''
                        export MOZ_APP_REMOTINGNAME=${lib.escapeShellArg id}
                        exec ${lib.getExe config.programs.${browser}.finalPackage} \
                          -P ${lib.escapeShellArg name} \
                          --name ${lib.escapeShellArg id} \
                          --class ${lib.escapeShellArg id} \
                          "$@"
                      '';
                    in (
                      lib.nameValuePair
                      id
                      {
                        name = "${prettyName} (${flib.capitalize name})";
                        genericName = "Web Browser";
                        comment = "Launch ${prettyName} with the ${name} profile";
                        exec = "${cmd} %U";
                        settings.StartupWMClass = id;
                        icon =
                          if (lib.hasAttr name iconOverrides)
                          then iconOverrides.${name} browser
                          else browser;
                        terminal = false;
                        startupNotify = true;
                        categories = [
                          "Network"
                          "WebBrowser"
                        ];
                      }
                    )
                  )
                )
            )
          );
        })
        # Darwin; create launcher packages
        (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          home.packages =
            config.gecko.configuredBrowsers
            |> builtins.concatMap (browser:
              lib.optionals
              config.programs.${browser}.enable
              (
                nonDefaultProfiles
                |> lib.mapAttrsToList (
                  name: profile: let
                    id = "${browser}-${name}";
                    prettyName = prettyNames.${browser};
                    appName = "${prettyName} (${flib.capitalize name})";
                    launcher = "${config.programs.${browser}.finalPackage}/Applications/${prettyName}.app";
                  in (
                    pkgs.runCommand
                    "${id}-launcher"
                    {
                      launcher =
                        pkgs.writeShellScript
                        id
                        ''
                          exec /usr/bin/open -n -a ${lib.escapeShellArg launcher} \
                            --args -P ${lib.escapeShellArg name} "$@"
                        '';
                      infoPlist =
                        pkgs.writeText
                        "${id}.plist"
                        (
                          lib.generators.toPlist
                          {escape = true;}
                          {
                            CFBundleName = appName;
                            CFBundleDisplayName = appName;
                            CFBundleIdentifier = "local.${browser}-profile.${name}";
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
                      cp ${
                        lib.escapeShellArg
                        "${launcher}/Contents/Resources/firefox.icns"
                      } \
                        "$app/Contents/Resources/firefox.icns"
                    ''
                  )
                )
              ));
        })
      ]
    ));
  };
}
