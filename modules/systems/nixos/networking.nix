# Networking tools to install to userspace
{inputs, ...}: {
  den = {
    aspects.system = {
      # This provides already included inside the system aspect
      provides.networking = {
        # Firewall port opening from quirk
        nixos = {
          local-ports,
          lib,
          ...
        }: {
          imports = [
            inputs.self.modules.nixos.nixos-networking
          ];
          config = {
            networking.firewall = {
              # Load all port specifications from
              allowedTCPPorts =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["tcp" "all"])
                |> builtins.filter (p: p ? port)
                |> builtins.map (p: p.port)
                |> lib.lists.unique;
              allowedTCPPortRanges =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["tcp" "all"])
                |> builtins.filter (p: ((p ? from) && (p ? to)))
                |> builtins.map (p: {inherit (p) from to;})
                |> lib.lists.unique;
              allowedUDPPorts =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["udp" "all"])
                |> builtins.filter (p: p ? port)
                |> builtins.map (p: p.port)
                |> lib.lists.unique;
              allowedUDPPortRanges =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["udp" "all"])
                |> builtins.filter (p: ((p ? from) && (p ? to)))
                |> builtins.map (p: {inherit (p) from to;})
                |> lib.lists.unique;
            };
          };
        };

        # Included in system._.networking in modusles/systems/networking.nix
        provides.local-web = {host}: {
          # Using nginx for local address resolution
          nixos = {
            local-pages,
            lib,
            pkgs,
            ...
          }: let
            # Attrset for pages, and normalize the record
            localPages = builtins.head local-pages;
          in {
            config = lib.mkIf (host.localWeb.enable) {
              # Set up host domain on local
              networking.hosts."127.0.0.1" =
                localPages
                |> builtins.attrNames
                |> builtins.map (s: "${s}.localhost");
              # Set up nginx
              services.nginx = {
                enable = lib.mkDefault true;
                virtualHosts =
                  localPages
                  |> lib.mapAttrs' (
                    service: routes:
                      lib.nameValuePair
                      "${service}.localhost"
                      {
                        listen = [
                          {
                            addr = "127.0.0.1";
                            port = 80;
                          }
                          {
                            addr = "[::1]";
                            port = 80;
                          }
                        ];
                        # Main transformation
                        locations =
                          (
                            routes
                            |> lib.mapAttrs (
                              path: route:
                                if route ? port
                                then {
                                  proxyPass = "http://127.0.0.1:${builtins.toString route.port}/";
                                  proxyWebsockets = true;
                                  recommendedProxySettings = true;
                                  extraConfig = ''
                                    proxy_read_timeout 600s;
                                    proxy_send_timeout 600s;
                                  '';
                                }
                                else if route ? root
                                then {
                                  # Normalize paths from a package
                                  root =
                                    if builtins.isFunction route.root
                                    then route.root {inherit pkgs;}
                                    else route.root;
                                  tryFiles = "$uri $uri/ $uri.html /index.html";
                                }
                                else throw "Local web route ${path} has no port or static root"
                            )
                          )
                          // (
                            routes
                            |> lib.filterAttrs (path: _: path != "/")
                            |> lib.mapAttrs' (
                              path: _:
                                lib.nameValuePair
                                "= ${lib.removeSuffix "/" path}"
                                {return = "308 ${path}";}
                            )
                          );
                      }
                  );
              };
            };
          };
        };
      };
    };
  };

  # Networking module
  flake.modules.nixos.nixos-networking = {pkgs, ...}: {
    # Dispatch local LAN keys as trusted
    security.pki.certificates = [
      (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
    ];

    environment.systemPackages = with pkgs; [
      # Monitoring tools
      nethogs # Per-process network usage
      iftop # Network bandwidth monitoring
      net-tools # Connection monitoring
      tcpdump # Packet capture

      # Basic network utilities
      curl
      wget
      dig
      nmap
    ];
  };
}
