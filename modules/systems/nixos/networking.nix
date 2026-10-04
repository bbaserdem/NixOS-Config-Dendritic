# Networking tools to install to userspace
{
  inputs,
  den,
  lib,
  ...
}: {
  # System aspect
  den = {
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.networking
          den.aspects.system._.nixos.policies.local-pages-dispatch
        ];
        policies = {
          local-pages-dispatch = {host, ...}:
            lib.optionals
            host.networking.local.enable
            [
              ( # Needs local web server
                den.lib.policy.include
                den.aspects.networking._.nginx
              )
              (
                den.lib.policy.include
                den.aspects.system._.nixos._.networking._.local-pages
              )
            ];
        };

        provides.networking = {
          name = "system/nixos/networking";
          # NixOS default networking settings
          nixos = {
            local-ports,
            lib,
            ...
          }: {
            imports = [
              inputs.self.modules.nixos.nixos-networking
            ];
            config = {
              # Open specified ports in default firewall implementation
              networking.firewall = {
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

          # Serve local web pages (enables nginx)
          provides.local-pages = {host}: {
            name = "system/nixos/networking/local-pages(@${host.name})";
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
              config = {
                # Set up host domain on local
                networking.hosts."127.0.0.1" =
                  localPages
                  |> builtins.attrNames
                  |> builtins.map (s: "${s}.localhost");
                # Set up nginx
                services.nginx = {
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
  };

  # Modules
  flake.modules.nixos.nixos-networking = {pkgs, ...}: {
    # Generic networking
    key = "nixos-networking#nixos";
    config = {
      # Dispatch local LAN keys as trusted
      security.pki.certificates = [
        (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
      ];
      # Userspace tools
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
  };
}
