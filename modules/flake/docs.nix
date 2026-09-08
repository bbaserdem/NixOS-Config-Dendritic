# Serve documentation as a local website
{
  den,
  lib,
  ...
}: {
  den = {
    schema.host = {
      options.localWeb = lib.mkOption {
        type = lib.types.submodule {
          options = {
            docs = lib.mkOption {
              description = "Whether to enable serving local documentation";
              type = lib.types.bool;
              default = true;
            };
          };
        };
      };
    };

    aspects.system.provides.networking = {
      includes = [
        den.aspects.system._.networking.policies.add-documentation
      ];
      # Auto-enable documentation if host enabled it
      policies.add-documentation = {host, ...}:
        lib.optionals (host.localWeb.docs)
        [(den.lib.policy.include den.aspects.system._.networking._.system-docs)];

      # Aspect for providing the documentation static page
      provides.system-docs = {host}: {
        # Use the host variable to silece linter
        name = "networking/system-docs(${host.name})";
        # Add to system packages to install it even if localWeb.enable = false
        os = {pkgs, ...}: {
          environment.systemPackages = [pkgs.local.system-docs];
        };
        # Emit to host quirk; {pkgs, ...}: is emitted as a function
        local-web = {
          service = "system-docs";
          # Emit from package
          root = {pkgs, ...}: "${pkgs.local.system-docs}";
        };
      };
    };
  };

  # TODO: remove after den migration
  flake.modules = let
    localAddress = "system-docs";
  in {
    # In nixos, the service is nginx
    nixos.nginx = {pkgs, ...}: {
      networking.hosts."127.0.0.1" = ["${localAddress}.localhost"];

      services.nginx.virtualHosts."${localAddress}.localhost" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 80;
          }
        ];
        root = "${pkgs.local.system-docs}";
        locations."/".tryFiles = "$uri $uri/ $uri.html /index.html";
      };
    };

    # In darwin, the service is caddy
    darwin.caddy = {
      lib,
      pkgs,
      ...
    }: {
      local.services.caddy.virtualHosts."${localAddress}.localhost" = {
        listen = "http://${localAddress}.localhost";
        extraConfig = ''
          bind 127.0.0.1

          root * ${pkgs.local.system-docs}
          try_files {path} {path}/ {path}.html /index.html
          file_server
        '';
      };
      system.activationScripts.postActivation.text = lib.mkAfter ''
        if ! /usr/bin/grep -qE '^[[:space:]]*127[.]0[.]0[.]1[[:space:]].*${localAddress}[.]localhost' /etc/hosts; then
          /bin/echo '127.0.0.1 ${localAddress}.localhost' >> /etc/hosts
        fi
      '';
    };
  };
}
