# Filesystem navigation in gui
{
  inputs,
  den,
  lib,
  ...
}: let
  configuredFileBrowsers = [
    "dolphin"
  ];
in {
  den = {
    # Schema for default pick
    schema = {
      host = {
        includes = [
          den.aspects.desktop.policies.filebrowser-host-dispatch
        ];
        options = {
          desktop = lib.mkOption {
            type = lib.types.submodule {
              options = {
                fileBrowser = lib.mkOption {
                  description = "File browser app to include in userspace, if any.";
                  default = null;
                  type = lib.types.nullOr (lib.types.enum configuredFileBrowsers);
                };
              };
            };
          };
        };
      };
      user = {
        includes = [
          den.aspects.desktop.policies.filebrowser-user-dispatch
        ];
      };
    };

    aspects.desktop = {
      # Dispatch policies
      policies = {
        filebrowser-host-dispatch = {host, ...}:
          lib.optional
          (host.desktop.enable && (host.desktop.fileBrowser != null))
          (den.lib.policy.include den.aspects.desktop._.${host.desktop.fileBrowser});
        filebrowser-user-dispatch = {host, ...}:
          lib.optional
          (host.desktop.enable && (host.desktop.fileBrowser != null))
          (den.lib.policy.include den.aspects.desktop._.${host.desktop.fileBrowser}._.to-users);
      };

      # Filebrowsers; automated!
      provides =
        configuredFileBrowsers
        |> builtins.map (
          n:
            lib.nameValuePair
            n
            {
              name = "desktop/${n}";
              nixos = {...}: {
                imports = [
                  (inputs.self.modules.nixos."${n}-settings" or {})
                ];
              };
              darwin = {...}: {
                imports = [
                  (inputs.self.modules.darwin."${n}-settings" or {})
                ];
              };
              provides.to-users = {
                user,
                host,
              }: {
                name = "desktop/${n}(${user.userName}@${host.name})";
                homeManager = {...}: {
                  imports = [
                    (inputs.self.modules.homeManager."${n}-settings" or {})
                  ];
                };
              };
            }
        )
        |> builtins.listToAttrs;
    };
  };

  # Module
  flake.modules.homeManager.dolphin-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "dolphin-settings#homeManager";
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      home.packages = with pkgs; [
        kdePackages.dolphin
      ];
    };
  };
}
