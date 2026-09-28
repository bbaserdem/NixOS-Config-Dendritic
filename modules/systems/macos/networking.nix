# Configuring the local lan of darwin systems
{
  inputs,
  den,
  lib,
  ...
}: {
  den = {
    aspects.system = {
      provides.macos = {
        includes = [
          den.aspects.system._.macos._.networking
        ];

        provides.networking = {
          name = "system/macos/networking";
          # Darwin setup
          darwin = {...}: {
            imports = [
              inputs.self.modules.darwin.macos-networking
            ];
            # TODO: If we can do firewall stuff; get it here
          };
          # We send lan keys to everyone's home as well
          provides.to-users = {
            host,
            user,
          }: {
            name = "system/macos/networking(${user.userName}@${host.name})";
            # Send the lan certificates to everyones' home as well
            homeManager = {
              imports = [
                inputs.self.modules.homeManager.hm-networking
              ];
            };
          };

          # Serve local web pages (uses caddy module)
          includes = [
            den.aspects.system._.macos._.networking.policies.macos-local-pages-dispatch
          ];
          policies.macos-local-pages-dispatch = {host, ...}: (
            lib.optionals
            host.networking.enableLocalWeb
            (den.lib.policy.include den.aspects.system._.macos._.networking._.local-pages)
          );
          provides.local-pages = {host}: {
            name = "system/macos/networking/local-pages(@${host.name})";
            darwin = {
              local-pages,
              lib,
              pkgs,
              options,
              ...
            }: let
              # Get the records
              localPages = builtins.head local-pages;
              # Handler functions
              renderHandler = route:
                if route ? port
                then ''
                  reverse_proxy 127.0.0.1:${builtins.toString route.port}
                ''
                else if route ? root
                then ''
                  root * ${
                    builtins.toString (
                      if builtins.isFunction route.root
                      then route.root {inherit pkgs;}
                      else route.root
                    )
                  }
                  try_files {path} {path}/ {path}.html /index.html
                  file_server
                ''
                else throw "Local web route has no port or static root";
              renderRoute = path: route:
                if path == "/"
                then ''
                  handle {
                    ${renderHandler route}
                  }
                ''
                else ''
                  redir ${lib.removeSuffix "/" path} ${path} 308

                  handle_path ${path}* {
                    ${renderHandler route}
                  }
                '';
              renderRoutes = routes: ''
                route {
                  ${
                  routes
                  |> lib.filterAttrs (path: _: path != "/")
                  |> lib.mapAttrsToList renderRoute
                  |> lib.concatStringsSep "\n"
                }

                  ${
                  if builtins.hasAttr "/" routes
                  then renderRoute "/" routes."/"
                  else ''
                    handle {
                      respond 404
                    }
                  ''
                }
                }
              '';
            in {
              imports = [
                inputs.self.modules.darwin.caddy
              ];
              config = lib.optionalAttrs (options.services ? caddy) {
                # Enable caddy from our module
                services.caddy = {
                  # Enable caddy
                  enable = lib.mkDefault true;

                  # Setup for routing
                  virtualHosts =
                    localPages
                    |> lib.mapAttrs' (
                      service: routes:
                        lib.nameValuePair
                        "${service}.localhost"
                        {
                          listen = "http://${service}.localhost";
                          extraConfig = ''
                            bind 127.0.0.1 [::1]
                            ${renderRoutes routes}
                          '';
                        }
                    );
                };
              };
            };
          };
        };
      };
    };
  };

  flake.modules = {
    # Main networking module
    darwin.macos-networking = {...}: {
      key = "macos-networking#darwin";
      config = {
        # Dispatch local LAN keys as trusted
        security.pki.certificates = [
          (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
        ];
      };
    };
  };
}
