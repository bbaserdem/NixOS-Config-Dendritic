# Caddy, http proxy in darwin
{...}: {
  flake.modules.darwin.caddy = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.local.services.caddy;
    caddyFile = pkgs.writeText "Caddyfile" ''
      {
        auto_https off
        admin off
        ${cfg.globalConfig}
      }

      ${lib.concatStringsSep "\n\n" (
        lib.mapAttrsToList
        (name: v: ''
          ${v.listen} {
            ${v.extraConfig}
          }
        '')
        cfg.virtualHosts
      )}
    '';
  in {
    # Options to define
    options = {
      local.services.caddy = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable Caddy";
        };
        package = lib.mkPackageOption pkgs "caddy" {};
        globalConfig = lib.mkOption {
          type = lib.types.lines;
          default = "";
        };
        virtualHosts = lib.mkOption {
          default = {};
          type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
            options = {
              listen = lib.mkOption {
                type = lib.types.str;
                default = "http://${name}";
              };
              extraConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
              };
            };
          }));
        };
      };
    };

    # Configuration
    config = lib.mkIf (cfg.enable == true) {
      # Install caddy
      environment.systemPackages = [cfg.package];
      # Create log directories
      system.activationScripts.postActivation.text = lib.mkAfter ''
        mkdir -p /var/log/caddy
      '';
      # Register launchd daemon
      launchd.daemons.caddy = {
        command = "${cfg.package}/bin/caddy run --config ${caddyFile} --adapter caddyfile";
        serviceConfig = {
          RunAtLoad = true;
          KeepAlive = true;
          StandardOutPath = "/var/log/caddy/stdout.log";
          StandardErrorPath = "/var/log/caddy/stderr.log";
        };
      };
    };
  };
}
