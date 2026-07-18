# Aspect factory to drop user icon
{inputs, ...}: {
  factory.mkUserIconAspect = {
    default ? null,
    hosts ? {},
  }: {host}: let
    iconName = hosts.${host.name} or default;
    secretFile = inputs.self + "/secrets/assets/${iconName}.bin";
  in {
    # We do an include with anon aspect; to make this parametric on host, user
    # context, without disabling the non-dependent home-manager module
    includes = [
      (
        {
          host,
          user,
        }: {
          # Since anon (can't infer den base aspect to reference in factory)
          # We need to explicitly set aspect name use a name for dedupe
          name = "users/user-icon(${user.userName}@${host.name})";
          nixos = {
            config,
            lib,
            options,
            pkgs,
            ...
          }: let
            secretName = "user-profile-${user.userName}";
            serviceName = "accountsservice-avatar-${user.userName}";
            iconPath = "/var/lib/AccountsService/icons/${user.userName}";
            secretUnits = lib.optionals config.sops.useSystemdActivation [
              "sops-install-secrets.service"
            ];
          in {
            key = "frameworks-users/user-icon#nixos@${user.userName}/${host.name}";

            config = lib.optionalAttrs (options ? sops) (
              lib.mkIf (iconName != null) {
                # Enable account daemon
                services.accounts-daemon.enable = lib.mkDefault true;

                # Load the sops secret
                sops.secrets.${secretName} = {
                  format = "binary";
                  sopsFile = secretFile;
                  owner = "root";
                  group = "root";
                  mode = "0444";
                  path = iconPath;
                };

                # Create the systemd service to dispatch the account picture
                systemd.services.${serviceName} =
                  lib.mkIf
                  (config.services.accounts-daemon.enable) {
                    description = "Set AccountsService profile picture for ${user.userName}";

                    wantedBy = ["graphical.target"];
                    before = ["display-manager.service"];
                    after = ["accounts-daemon.service"] ++ secretUnits;
                    requires = ["accounts-daemon.service"] ++ secretUnits;

                    restartTriggers = [
                      config.sops.secrets.${secretName}.sopsFileHash
                    ];

                    serviceConfig = {
                      Type = "oneshot";
                      RemainAfterExit = true;
                    };

                    script = ''
                      uid="$(
                        ${pkgs.coreutils}/bin/id -u \
                          ${lib.escapeShellArg user.userName}
                      )"

                      ${pkgs.dbus}/bin/dbus-send --system \
                        --dest=org.freedesktop.Accounts \
                        --type=method_call \
                        --print-reply \
                        "/org/freedesktop/Accounts/User$uid" \
                        org.freedesktop.Accounts.User.SetIconFile \
                        string:${lib.escapeShellArg iconPath}
                    '';
                  };
              }
            );
          };
        }
      )
    ];

    # Also drop compatibility link in home-manager (for darwin and standaloneHm)
    homeManager = {
      lib,
      options,
      pkgs,
      config,
      ...
    }: let
      iconPath =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "${config.home.homeDirectory}/UserIcon.png"
        else "${config.home.homeDirectory}/.face.icon";
      secretName = "user-profile-${config.home.username}";
    in {
      config = lib.optionalAttrs (options ? sops) (
        lib.mkIf (iconName != null) {
          # Drop the sops file
          sops.secrets.${secretName} = {
            format = "binary";
            sopsFile = secretFile;
            mode = "0444";
            path = iconPath;
          };
        }
      );
    };
  };
}
