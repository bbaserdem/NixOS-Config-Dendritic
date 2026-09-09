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
      imports = [
        ({config, ...}: let
          userName = config.userName;
        in {
          options = {
            profile = lib.mkOption {
              description = "User profile customization settings";
              default = {};
              type = lib.types.submodule ({config, ...}: let
                variant = config.icon;
              in {
                options = {
                  icon = lib.mkOption {
                    description = ''
                      User profile icon to be dispatched.
                      When set (non-null), a profile picture will be dispatched.

                      This value must correspond to an existing *variant*.
                      Encrypted png file is secrets/assets/<user>_<variant>.bin
                      (File must be decryptable by both os and user)
                      File must decrypt to smaller than 1MiB (unix)
                    '';
                    default = null;
                    type = lib.types.nullOr lib.types.str;
                  };
                  iconFile = lib.mkOption {
                    description = "The resulting file path";
                    readOnly = true;
                    type = lib.types.nullOr lib.types.path;
                    default =
                      if config.icon == null
                      then null
                      else
                        inputs.self
                        + "/secrets/assets/"
                        + "${userName}_${variant}.bin";
                  };
                };
              });
            };
          };
        })
      ];
      includes = [
        den.aspects.user.policies.user-icon-dispatch
      ];
    };

    aspects.user = {
      # Policy for dispatching
      policies.user-icon-dispatch = {user, ...}:
        lib.optional
        (user.profile.icon != null)
        (den.lib.policy.include den.aspects.user._.profileIcon);

      provides.profileIcon = {
        host,
        user,
      }: {
        # Prevent collisions
        name = "user/profileIcon(${user.userName}@${host.name})";

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
                assertion = builtins.pathExists user.profile.iconFile;
                message = "Profile picture secret not found.";
              }
            ];
            # Enable account daemon
            services.accounts-daemon.enable = lib.mkDefault true;

            # Load the sops secret
            sops.secrets.${secretName} = {
              format = "binary";
              sopsFile = user.profile.iconFile;
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
                    assertion = builtins.pathExists user.profile.iconFile;
                    message = "Profile picture secret not found.";
                  }
                ];
                # Drop the sops file
                sops.secrets.${secretName} = {
                  format = "binary";
                  sopsFile = user.profile.iconFile;
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
