# D-Bus for darwin
{inputs, ...}: {
  flake.modules.darwin = {
    # The module for enables in macos
    macos-dbus = {...}: {
      key = "macos-dbus#darwin";
      # Import the required module
      imports = [
        inputs.self.modules.darwin.dbus-session
      ];
      # Enable dbus
      config = {
        services.dbus-session = {
          enable = true;
        };
      };
    };

    # The module that sets things up
    dbus-session = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.services.dbus-session;
    in {
      key = "dbus-session#darwin";
      options = {
        services.dbus-session = {
          enable = lib.mkEnableOption "D-Bus session bus for macOS login";
          package = lib.mkPackageOption pkgs "dbus" {};
        };
      };
      config = lib.mkIf cfg.enable {
        # Install dbus to system packages
        environment.systemPackages = [cfg.package];

        # Launchd settings; agents provides it to each login
        launchd.agents.dbus-session = {
          script = ''
            set -eu

            socket=$(/bin/launchctl getenv DBUS_LAUNCHD_SESSION_BUS_SOCKET)
            test -n "$socket"

            export DBUS_SESSION_BUS_ADDRESS="unix:path=$socket"

            /bin/launchctl setenv \
              DBUS_SESSION_BUS_ADDRESS \
              "$DBUS_SESSION_BUS_ADDRESS"

            exec ${cfg.package}/bin/dbus-daemon \
              --nofork \
              --nopidfile \
              --config-file=${cfg.package}/share/dbus-1/session.conf
          '';

          environment.XDG_DATA_DIRS = [
            "/run/current-system/sw/share"
            "/usr/local/share"
            "/usr/share"
          ];

          serviceConfig = {
            RunAtLoad = true;
            Sockets.unix_domain_listener = {
              SecureSocketWithKey = "DBUS_LAUNCHD_SESSION_BUS_SOCKET";
            };
          };
        };
      };
    };
  };
}
