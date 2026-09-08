# Configuring the local lan of darwin systems
{inputs, ...}: {
  den = {
    aspects.system = {
      provides.networking = {
        # Darwin setup
        darwin = {...}: {
          imports = [
            inputs.self.modules.darwin.macos-networking
          ];
          # TODO: If we can do port stuff, do it here
        };

        provides.local-web = {host}: {
          darwin = {
            local-pages,
            lib,
            pkgs,
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
            config = lib.mkIf (host.localWeb.enable) {
              # Enable caddy from our module
              local.services.caddy = {
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

  flake.modules.darwin = {
    # Main networking module
    macos-networking = {
      lib,
      options,
      ...
    }: {
      # Import the caddy option definition to our flake
      imports = [
        inputs.self.modules.darwin.caddy
      ];

      config = lib.mkMerge [
        {
          # Dispatch local LAN keys as trusted
          security.pki.certificates = [
            (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
          ];
        }
        (
          lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) {
            # Provision the local certificate to home-manager users as well,
            # Enables manual install
            home-manager.sharedModules = [
              {
                xdg.dataFile."certs/home-lan-ca.crt" = {
                  source = inputs.self + /assets/home-lan-ca.crt;
                };
              }
            ];
          }
        )
      ];
    };
  };
}
