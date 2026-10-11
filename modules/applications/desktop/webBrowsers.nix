# Web browsers to use
{
  inputs,
  den,
  lib,
  ...
}: let
  configuredWebBrowsers = [
    "firefox"
    "librewolf"
    "chromium"
    "google-chrome"
  ];
in {
  den = {
    # Schema for default pick
    schema = {
      host = {
        includes = [
          den.aspects.desktop.policies.webbrowser-host-dispatch
        ];
        options = {
          desktop = lib.mkOption {
            type = lib.types.submodule {
              options = {
                webBrowsers = lib.mkOption {
                  description = "Web browser's app(s) to include in userspace, if any.";
                  default = [];
                  type = lib.types.listOf (lib.types.enum configuredWebBrowsers);
                };
              };
            };
          };
        };
      };
      user.includes = [
        den.aspects.desktop.policies.webbrowser-user-dispatch
      ];
    };

    aspects.desktop = {
      # Dispatch policies
      policies = {
        webbrowser-host-dispatch = {host, ...}:
          lib.optionals
          (host.desktop.enable && (host.desktop.webBrowsers != []))
          (
            [(den.lib.policy.include den.aspects.desktop._.webbrowser)]
            ++ (
              host.desktop.webBrowsers
              |> builtins.map (
                n: (
                  den.lib.policy.include
                  den.aspects.desktop._.webbrowser._.${n}
                )
              )
            )
          );
        webbrowser-user-dispatch = {host, ...}:
          lib.optionals
          (host.desktop.enable && (host.desktop.webBrowsers != []))
          (
            [(den.lib.policy.include den.aspects.desktop._.webbrowser._.to-users)]
            ++ (
              host.desktop.webBrowsers
              |> builtins.map (
                n: (
                  den.lib.policy.include
                  den.aspects.desktop._.webbrowser._.${n}._.to-users
                )
              )
            )
          );
      };

      provides.webbrowser = {
        name = "desktop/webbrowser";
        provides.to-users = {
          user,
          host,
        }: {
          name = "desktop/webbrowser(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.desktop-psd
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.desktop-psd = {
    pkgs,
    lib,
    ...
  }: {
    key = "desktop-psd#homeManager";
    # PSD is linux only
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      services.psd = {
        enable = true;
        browsers = lib.mkDefault [];
      };
    };
  };
}
