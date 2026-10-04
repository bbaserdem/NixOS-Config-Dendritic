# Samba: file sharing
{
  inputs,
  den,
  lib,
  flib,
  ...
}: {
  den = {
    schema = {
      host = {
        includes = [
          den.aspects.networking.policies.samba-host-dispatch
        ];
        options = {
          networking = lib.mkOption {
            type = lib.types.submodule {
              options = {
                samba = lib.mkOption {
                  description = "Samba file sharing daemon";
                  default = {};
                  type = lib.types.submodule {
                    options = {
                      enable = lib.mkOption {
                        description = "Enable samba on this host";
                        default = false;
                        type = lib.types.bool;
                      };
                      allowedHosts = lib.mkOption {
                        description = "List of allowed hosts";
                        default = ["192.168.1.0/24"];
                        type = lib.types.listOf lib.types.str;
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          den.aspects.networking.policies.samba-user-dispatch
        ];
        imports = [
          ({config, ...}: {
            options = {
              samba = lib.mkOption {
                description = "Samba share options for this user";
                default = {};
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      description = "Enable sharing a folder using this device";
                      default = config.host.networking.samba.enable;
                      type = lib.types.bool;
                    };
                    location = lib.mkOption {
                      description = "Samba share location to share; relative to ~";
                      type = flib.types.relativePath;
                      default =
                        if (config.mediaDirs != null) && (config.mediaDirs ? publicShare)
                        then config.mediaDirs.publicShare.location
                        else if lib.hasSuffix "-darwin" config.host.system
                        then "Public"
                        else "Shared/Public";
                    };
                    readOnly = lib.mkOption {
                      description = "Only allow reads; don't allow writes.";
                      default = true;
                      type = lib.types.bool;
                    };
                    guest = lib.mkOption {
                      description = "Allow guests to interact.";
                      default = true;
                      type = lib.types.bool;
                    };
                  };
                };
              };
            };
          })
        ];
      };
    };

    aspects.networking = {
      # Dispatch policies
      policies = {
        samba-host-dispatch = {host, ...}:
          lib.optional
          host.networking.samba.enable
          (den.lib.policy.include den.aspects.networking._.samba);
        samba-user-dispatch = {
          user,
          host,
          ...
        }:
          lib.optional
          (host.networking.samba.enable && user.samba.enable)
          (den.lib.policy.include den.aspects.networking._.samba._.user-setup);
      };

      # Aspect
      provides.samba = {
        name = "networking/samba";
        # TODO: Do ports with our quirk as well
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.samba
          ];
        };

        # Personal share access
        provides.user-setup = {
          user,
          host,
        }: {
          name = "networking/samba(${user.userName}@${host.name})";
          nixos = {
            lib,
            options,
            config,
            ...
          }: let
            unitName = "samba-user-${user.userName}";
            sharePath = "${user.homeDirectory}/${user.samba.location}";
            shareName = "${user.userName}@${host.name}-public";
          in {
            config = lib.mkMerge [
              ( # Samba password for the user; needs sops
                lib.optionalAttrs (options ? sops) {
                  # Fetch from sops
                  sops.secrets."samba/${user.userName}" = {
                    sopsFile = inputs.self + /secrets/host/secrets.yaml;
                    mode = "0400";
                    restartUnits = ["${unitName}.service"];
                  };
                  # Service to set up samba password for user

                  # Set samba user password
                  systemd.services.${unitName} = {
                    description = "Provision Samba password for user:${user.userName}";
                    wantedBy = ["multi-user.target"];
                    after = ["samba-smbd.service"];
                    requires = ["samba-smbd.service"];
                    path = [config.services.samba.package];
                    serviceConfig = {
                      Type = "oneshot";
                      RemainAfterExit = true;
                      LoadCredential = [
                        "samba-password:${config.sops.secrets."samba/${user.userName}".path}"
                      ];
                    };
                    script = ''
                      password="$(cat "$CREDENTIALS_DIRECTORY/samba-password")"

                      printf '%s\n%s\n' "$password" "$password" \
                        | smbpasswd -s -a ${user.userName}
                      smbpasswd -e ${user.userName}
                    '';
                  };
                }
              )
              {
                # Samba settings
                services.samba.settings.${shareName} =
                  {
                    comment = "${user.userName}'s public share on ${host.name}";
                    path = sharePath;
                    # Searchability
                    browseable = "yes";
                    "guest ok" = flib.yesNo user.samba.guest;
                    "read only" = flib.yesNo user.samba.readOnly;
                    # Permissions
                    "create mask" = "0664";
                    "directory mask" = "0775";
                    # User role
                    "force user" = user.userName;
                    "force group" = config.users.users.${user.userName}.group;
                    # Allow/deny list
                    "hosts allow" = host.networking.samba.allowedHosts;
                    "hosts deny" = [
                      "0.0.0.0/0"
                      "::/0"
                    ];
                  }
                  // (lib.optionalAttrs (!user.samba.guest) {
                    "valid users" = user.userName;
                  });
              }
            ];
          };
        };
      };
    };
  };

  # Main module
  flake.modules.nixos.samba = {...}: {
    key = "samba#nixos";
    config = {
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
        # Advertise our samba to windows as well
        samba-wsdd = {
          enable = true;
          openFirewall = true;
        };
      };
    };
  };
}
