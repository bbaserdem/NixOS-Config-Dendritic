# D-Bus for darwin
{inputs, ...}: {
  den.aspects = {
    system = {
      # This dispatch handled by system.darwin parametric aspect
      provides.macos-dbus = {
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.macos-dbus
          ];
        };
        provides.to-users = {
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.macos-dbus
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules = {
    # Session bus
    homeManager = {
      macos-dbus = {...}: {
        key = "macos-dbus#homeManager";
        # Import the required module
        imports = [
          inputs.self.modules.homeManager.darwin-dbus-session
        ];
        config = {
          services.dbus-session = {
            enable = true;
          };
        };
      };
      darwin-dbus-session = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.dbus-session;
      in {
        key = "darwin-dbus-session#homeManager";
        options = {
          services.dbus-session = {
            enable = lib.mkEnableOption "D-Bus session bus for macOS.";
            package = lib.mkPackageOption pkgs "dbus" {};
          };
        };
        config = lib.mkMerge [
          {
            # Don't tolerate this module loading outside darwin context
            assertions = [
              {
                assertion = pkgs.stdenv.hostPlatform.isDarwin;
                message = ''
                  The module `darwin-dbus-session#homeManager` is imported outside darwin context.
                '';
              }
            ];
          }
          (
            lib.mkIf cfg.enable {
              # Install dbus
              home.packages = [cfg.package];
              # Launchd registry
              launchd.agents.dbus-session = {
                enable = true;
                config = {
                  Label = "org.freedesktop.dbus-session";
                  ProgramArguments = [
                    "${pkgs.writeShellScript "dbus-session-start" ''
                      set -eu

                      socket="''${DBUS_LAUNCHD_SESSION_BUS_SOCKET:?launchd did not provide a D-Bus socket}"
                      address="unix:path=$socket"

                      /bin/launchctl setenv DBUS_LAUNCHD_SESSION_BUS_SOCKET "$socket"
                      /bin/launchctl setenv DBUS_SESSION_BUS_ADDRESS "$address"

                      exec ${cfg.package}/bin/dbus-daemon \
                        --nofork \
                        --nopidfile \
                        --address=launchd:env=DBUS_LAUNCHD_SESSION_BUS_SOCKET \
                        --config-file=${cfg.package}/share/dbus-1/session.conf
                    ''}"
                  ];
                  RunAtLoad = true;
                  KeepAlive.SuccessfulExit = false;

                  EnvironmentVariables = {
                    HOME = config.home.homeDirectory;
                    XDG_DATA_HOME = config.xdg.dataHome;
                    XDG_DATA_DIRS = lib.concatStringsSep ":" [
                      "${config.home.profileDirectory}/share"
                      "/run/current-system/sw/share"
                      "/usr/local/share"
                      "/usr/share"
                      "/opt/homebrew/share"
                    ];
                  };

                  Sockets.unix_domain_listener = {
                    SecureSocketWithKey = "DBUS_LAUNCHD_SESSION_BUS_SOCKET";
                  };
                };
              };
            }
          )
        ];
      };
    };

    # System bus
    darwin = {
      # The module for enables the system dbus in darwin; root level
      macos-dbus = {...}: {
        key = "macos-dbus#darwin";
        # Import the required module
        imports = [
          inputs.self.modules.darwin.darwin-dbus-system
        ];
        config = {
          services.dbus = {
            enable = true;
          };
        };
      };

      # Module for setup
      darwin-dbus-system = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.dbus;
        # Create custom config
        baseDbusConfig = pkgs.makeDBusConf.override {
          dbus = cfg.dbusPackage;
          apparmor = "disabled";
          serviceDirectories = [cfg.dbusPackage] ++ cfg.packages;
          # The helper is not setuid in the Nix store. System services
          # should instead be managed as explicit LaunchDaemons.
          suidHelper = "/bin/false";
        };
        dbusConfig = pkgs.runCommand "dbus-1-darwin" {} ''
          mkdir -p "$out"
          cp -R ${baseDbusConfig}/. "$out/"
          chmod -R u+w "$out"
          # Match Homebrew and use macOS's existing daemon account.
          substituteInPlace "$out/system.conf" \
            --replace-fail \
              '<user>messagebus</user>' \
              '<user>daemon</user>'
        '';
      in {
        key = "darwin-dbus-system#darwin";
        # Options miror as closely to nixos as possible
        options = {
          services.dbus = {
            enable = lib.mkEnableOption "D-Bus system bus for macOS.";
            dbusPackage = lib.mkPackageOption pkgs "dbus" {};
            packages = lib.mkOption {
              type = lib.types.listOf lib.types.path;
              default = [];
              description = ''
                Packages whose D-Bus configuration files should be included in
                the configuration of the D-Bus system-wide.

                NOTE: .service activation is unsupported, corresponding
                service requires LaunchDaemons. Example;
                >   services.dbus.packages = [
                >     packageProvidingDbusPolicy
                >   ];
                >
                >   launchd.daemons.example-service = {
                >     serviceConfig = {
                >       ProgramArguments = [
                >         (lib.getExe packageProvidingDbusPolicy)
                >       ];
                >       RunAtLoad = true;
                >       KeepAlive = true;
                >       UserName = "_example";
                >     };
                >   };
              '';
            };
            configFile = lib.mkOption {
              type = lib.types.str;
              default = "dbus-1/system.conf";
              description = "Location for the system config file in /etc";
            };
          };
        };
        config = lib.mkIf cfg.enable {
          # Install dbus to system packages
          environment.systemPackages = [cfg.dbusPackage];

          # Create the configuration
          environment.etc."${cfg.configFile}".source = "${dbusConfig}/system.conf";

          # Launchd settings; agents provides it to each login
          launchd.daemons.dbus-system = {
            script = ''
              set -eu

              /bin/mkdir -p /run/dbus /var/lib/dbus
              /bin/chmod 0755 /run/dbus /var/lib/dbus

              ${cfg.dbusPackage}/bin/dbus-uuidgen \
                --ensure=/var/lib/dbus/machine-id

              exec ${cfg.dbusPackage}/bin/dbus-daemon \
                --nofork \
                --nopidfile \
                --address=unix:path=/run/dbus/system_bus_socket \
                --config-file=/etc/${cfg.configFile}
            '';

            serviceConfig = {
              Label = "org.freedesktop.dbus-system";
              RunAtLoad = true;
              KeepAlive.SuccessfulExit = false;
              ProcessType = "Background";
            };
          };

          # Activation script to restart the bus
          system.activationScripts.postActivation.text = lib.mkAfter ''
            oldConfig=/run/current-system/etc/${cfg.configFile}
            newConfig=$systemConfig/etc/${cfg.configFile}

            if [[ -e "$oldConfig" ]] && ! cmp -s "$oldConfig" "$newConfig"; then
              if /bin/launchctl print \
                system/org.freedesktop.dbus-system >/dev/null 2>&1
              then
                echo "reloading D-Bus system configuration" >&2
                /bin/launchctl kill SIGHUP system/org.freedesktop.dbus-system
              fi
            fi
          '';
        };
      };
    };
  };
}
