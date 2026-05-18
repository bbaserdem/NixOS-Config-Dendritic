# Samba: file sharing
{inputs, ...}: {
  flake = {
    modules.nixos.samba = {...}: {
      services = {
        samba = {
          enable = true;
          openFirewall = true;

          settings = {
            # Global settings
            global = {
              workgroup = "WORKGROUP";
              "server string" = "%h";
              "map to guest" = "Bad User";
              "server role" = "standalone server";
            };
          };
        };
        # Advertise our samba to  windows as well
        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
      };
    };

    # Factory function to generate user shared directories
    factory.userSamba = {
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
        config = lib.mkMerge [
          # Provision user a samba password, regardless of usage
          (
            lib.optionalAttrs (lib.hasAttrByPath ["sops" "secrets"] options) (
              lib.mkIf (config.services.samba.enable) (
                let
                  unitName = "samba-user-${user}.service";
                in {
                  # Load samba secret
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
          )
          # Provision shared directory if enabled
          (lib.optionalAttrs (lib.hasAttrByPath ["home-manager" "users"] options) (
            lib.mkIf (config.services.samba.enable && sambaShare) (
              let
                capitalize = s:
                  if s == ""
                  then ""
                  else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (builtins.stringLength s) s);
                sharePath = config.home-manager.users."${user}".xdg.userDirs.publicShare;
                shareName = "${user}@${config.networking.hostName}-public";
                sharePretty = "${capitalize user}'s public share on ${config.networking.hostName}";
                yesNo = v:
                  if v
                  then "yes"
                  else "no";
                group = config.users.users."${user}".group;
              in {
                # Make sure file exists with proper permissions
                systemd.tmpfiles.settings."30-samba-public-${user}"."${sharePath}".d = {
                  user = user;
                  group = group;
                  mode =
                    if readOnly
                    then "0755"
                    else "0775";
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
          ))
        ];
      };
    };
  };
}
