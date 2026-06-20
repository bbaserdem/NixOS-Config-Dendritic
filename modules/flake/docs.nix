# Serve documentation as a local website
{...}: {
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
