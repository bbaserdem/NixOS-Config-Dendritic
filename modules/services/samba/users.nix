# Samba: factory function for setting up users
{inputs, ...}: {
  # Factory function to;
  # - register user with password for samba
  # - create a network share if enabled
  factory.sambaUser = {
    user,
    guest ? false,
    readOnly ? false,
    sambaShare ? false,
    hostsAllow ? null,
    ...
  }: {
    nixos."${user}" = {
      config,
      lib,
      options,
      ...
    }: {
      config = lib.mkIf (config.services.samba.enable) (lib.mkMerge [
        # Provision user a samba password
        (
          lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) (
            let
              unitName = "samba-user-${user}";
            in {
              # Load samba secret from global config
              sops.secrets."samba/${user}" = {
                sopsFile = inputs.self + /secrets/host/secrets.yaml;
                mode = "0400";
                restartUnits = [unitName];
              };
              # Set samba user password
              systemd.services.${unitName} = {
                description = "Provision Samba password for user:${user}";
                wantedBy = ["multi-user.target"];
                after = ["samba-smbd.service"];
                requires = ["samba-smbd.service"];
                path = [
                  config.services.samba.package
                ];
                serviceConfig = {
                  Type = "oneshot";
                  RemainAfterExit = true;
                  LoadCredential = [
                    "samba-password:${config.sops.secrets."samba/${user}".path}"
                  ];
                };
                script = ''
                  password="$(cat "$CREDENTIALS_DIRECTORY/samba-password")"

                  printf '%s\n%s\n' "$password" "$password" | smbpasswd -s -a ${user}
                  smbpasswd -e ${user}
                '';
              };
            }
          )
        )
        (
          # Provision shared directory if enabled and requested
          lib.optionalAttrs ((lib.hasAttrByPath ["home-manager" "users"] options) && sambaShare) (
            let
              home = config.users.users.${user}.home;
              sharePath = config.home-manager.users."${user}".xdg.userDirs.publicShare;
              shareWalk = lib.init (inputs.self.lib.walkToDir home sharePath);
              shareParentPaths =
                if shareWalk == []
                then []
                else lib.init shareWalk;
              parentMode = "0750";
              shareMode =
                if readOnly
                then "0755"
                else "0775";
              shareName = "${user}@${config.networking.hostName}-public";
              sharePretty = "${inputs.self.lib.capitalize user}'s public share on ${config.networking.hostName}";
              yesNo = v:
                if v
                then "yes"
                else "no";
              group = config.users.users."${user}".group;
            in {
              # Make sure file exists with proper permissions
              # Create parent directory hierarchy
              systemd.tmpfiles.settings."29-samba-public-parents-${user}" = (
                lib.listToAttrs (
                  map (path:
                    lib.nameValuePair path {
                      d = {
                        inherit user group;
                        mode = parentMode;
                      };
                    })
                  shareParentPaths
                )
              );
              # Set permissions of the terminal share directory
              systemd.tmpfiles.settings."30-samba-public-${user}"."${sharePath}".d = {
                inherit user group;
                mode = shareMode;
              };
              # Create samba share
              services.samba.settings.${shareName} =
                {
                  comment = sharePretty;
                  path = sharePath;
                  browseable = "yes";
                  "read only" = yesNo readOnly;
                  "guest ok" = yesNo guest;
                  "create mask" = "0664";
                  "directory mask" = "0775";
                  "force user" = user;
                  "force group" = group;
                }
                // (
                  lib.optionalAttrs (hostsAllow != null) {
                    "hosts allow" = hostsAllow;
                    "hosts deny" = "0.0.0.0/0";
                  }
                )
                // (
                  lib.optionalAttrs (guest == false) {
                    "valid users" = user;
                  }
                );
            }
          )
        )
      ]);
    };
  };
}
