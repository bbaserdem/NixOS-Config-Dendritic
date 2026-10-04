# Nginx; web server and reverse proxy; in linux
{inputs, ...}: {
  # Den aspect
  den = {
    aspects.networking = {
      provides.nginx = {
        name = "networking/nginx";
        nixos = {...}: {
          imports = [
            inputs.self.modules.nixos.nginx-settings
          ];
        };
        # Open local ports
        # TODO: enable this only through metadata
        # local-ports = [
        #   {
        #     proto = "tcp";
        #     port = 80;
        #   }
        #   {
        #     proto = "tcp";
        #     port = 443;
        #   }
        # ];
      };
    };
  };

  # Module
  flake.modules.nixos.nginx-settings = {...}: {
    key = "nginx-settings#nixos";
    config = {
      services.nginx = {
        enable = true;
      };
    };
  };
}
