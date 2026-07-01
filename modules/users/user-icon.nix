# Dispatch user profile picture
{
  inputs,
  config,
  lib,
  ...
}: let
  users = config.localConfig.users;

  profileType = lib.types.submodule {
    freeformType = lib.types.attrsOf (lib.types.nullOr lib.types.str);

    options.global = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Global profile image name under sops.
      '';
    };
  };
in {
  options = {
    localConfig.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.profile = lib.mkOption {
          type = profileType;
          default = {};
          description = ''
            Profile image selector.
            Values are names under secrets/assets without .bin.
          '';
        };
      });
    };
  };

  config = {
    flake.modules.nixos =
      users
      |> lib.mapAttrs' (
        user: userCfg: (
          lib.nameValuePair "${user}" (
            {
              config,
              lib,
              pkgs,
              options,
              ...
            }: let
              userProfile = userCfg.profile or {};
              hostName = config.networking.hostName;
              profileName =
                if builtins.hasAttr hostName userProfile
                then userProfile.${hostName}
                else userProfile.global or null;
              sopsName = "user-profile-${user}";
              sopsFile = inputs.self + "/secrets/assets/${profileName}.bin";
              sopsPath = "/var/lib/AccountsService/icons/${user}";
            in {
              config =
                lib.optionalAttrs
                (lib.hasAttrByPath ["sops"] options) (
                  lib.mkIf (profileName != null) {
                    # Load the secret file
                    sops.secrets.${sopsName} = {
                      format = "binary";
                      sopsFile = sopsFile;
                      owner = "root";
                      group = "root";
                      mode = "0444";
                      path = sopsPath;
                    };

                    systemd.services."accountsservice-avatar-${user}" = {
                      description = "Set AccountsService profile picture for ${user}";

                      wantedBy = ["graphical.target"];
                      before = ["display-manager.service"];
                      # useSystmedActivation will produce sops-install-secrets.service
                      # But we have it disabled due to incompatibility with cryptsetup decryption
                      after = [
                        "accounts-daemon.service"
                        # "sops-install-secrets.service"
                      ];
                      requires = [
                        "accounts-daemon.service"
                        # "sops-install-secrets.service"
                      ];

                      restartTriggers = [config.sops.secrets.${sopsName}.sopsFileHash];

                      path = [
                        pkgs.coreutils
                        pkgs.dbus
                      ];

                      serviceConfig = {
                        Type = "oneshot";
                        RemainAfterExit = true;
                      };

                      script = ''
                        uid="$(id -u ${lib.escapeShellArg user})"

                        dbus-send --system \
                          --dest=org.freedesktop.Accounts \
                          --type=method_call \
                          --print-reply \
                          "/org/freedesktop/Accounts/User$uid" \
                          org.freedesktop.Accounts.User.SetIconFile \
                          string:${lib.escapeShellArg sopsPath}
                      '';
                    };
                  }
                );
            }
          )
        )
      );
  };
}
