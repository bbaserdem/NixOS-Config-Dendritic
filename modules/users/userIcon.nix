# Drop in user icon
{
  lib,
  den,
  inputs,
  ...
}: let
in {
  den = {
    schema.user = {
      options = {
        icon = lib.mkOption {
          description = "Encrypted user icon to be dispatched";
          default = null;
          type = lib.types.nullOr lib.types.str;
        };
      };
      includes = [
        den.aspects.userIcon.policies.user-icon-dispatch
      ];
    };

    aspects.userIcon = {
      # Policy for dispatching
      policies.user-icon-dispatch = {user, ...}:
        lib.optional
        (user.icon != null)
        (den.lib.policy.include den.aspects.userIcon._.set-user-icon);

      provides.set-user-icon = {
        host,
        user,
      }: let
        filePath = "/secrets/assets/${user.userName}_${user.icon}.bin";
      in {
        # Prevent collisions
        name = "userIcon(${user.userName}@${host.name})";

        # Nixos module that decrypts and sets the icon
        nixos = {
          config,
          lib,
          options,
          pkgs,
          ...
        }: let
          secretName = "user-profile-${user.userName}";
          iconPath = "/var/lib/AccountsService/icons/${user.userName}";
          secretUnits =
            lib.optionals
            (config.sops.useSystemdActivation or false)
            ["sops-install-secrets.service"];
        in {
          config = lib.optionalAttrs (options ? sops) {
            # Check if file exists
            assertions = [
              {
                assertion = builtins.pathExists (inputs.self + filePath);
                message = "Profile picture secret not found in `${filePath}`";
              }
            ];
            # Enable account daemon
            services.accounts-daemon.enable = lib.mkDefault true;

            # Load the sops secret
            sops.secrets.${secretName} = {
              format = "binary";
              sopsFile = inputs.self + filePath;
              owner = "root";
              group = "root";
              mode = "0444";
              path = iconPath;
            };

            # Create the systemd service to dispatch the account picture
            systemd.services."accountsservice-avatar-${user.userName}" =
              lib.mkIf
              (config.services.accounts-daemon.enable)
              {
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
          };
        };

        # Compatibility link in home-manager
        homeManager = {
          lib,
          options,
          pkgs,
          config,
          ...
        }: let
          secretName = "user-profile-${user.userName}";
        in {
          config = lib.optionalAttrs (options ? sops) (
            lib.mkMerge [
              {
                # Check if file exists
                assertions = [
                  {
                    assertion = builtins.pathExists (inputs.self + filePath);
                    message = "Profile picture secret not found in `${filePath}`";
                  }
                ];
                # Drop the sops file
                sops.secrets.${secretName} = {
                  format = "binary";
                  sopsFile = inputs.self + filePath;
                  mode = "0444";
                  path =
                    if pkgs.stdenv.hostPlatform.isDarwin
                    then "${user.homeDirectory}/UserIcon.png"
                    else "${user.homeDirectory}/.face.icon";
                };
              }
              (
                # Additional compat links
                lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
                  home.file.".face".source =
                    config.lib.file.mkOutOfStoreSymlink
                    config.sops.secrets.${secretName}.path;
                }
              )
            ]
          );
        };
      };
    };
  };
}
