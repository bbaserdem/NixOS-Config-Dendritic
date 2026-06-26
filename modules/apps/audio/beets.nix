# Enabling beets
{...}: {
  flake.modules = {
    homeManager.beets = {
      pkgs,
      config,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        {
          # Enable beets in userspace
          # The rest of the config should be user-specific
          programs.beets = {
            enable = true;
          };
        }
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Get GUI tagger
            home.packages = with pkgs; [
              picard
            ];

            # Create systemd-unit for web UI, disabled by default
            # Should be enabled by users explicitly
            systemd.user.services.beets-web = {
              Unit = {
                Description = "Beets Web UI";
                After = ["network.target"];
              };
              Service = {
                ExecStart = "${config.programs.beets.package}/bin/beet web";
                Restart = "on-failure";
              };
              Install.WantedBy = lib.mkDefault [];
            };
          }
        )
        # Create log/cache paths if we can
        (
          lib.mkIf
          (lib.hasPrefix "${config.home.homeDirectory}/" config.programs.beets.settings.import.log)
          {
            home.file."${lib.removePrefix "${config.home.homeDirectory}/" config.programs.beets.settings.import.log}/.keep".text = "";
          }
        )
        (
          lib.mkIf
          (lib.hasPrefix "${config.home.homeDirectory}/" config.programs.beets.settings.library)
          {
            home.file."${lib.removePrefix "${config.home.homeDirectory}/" config.programs.beets.settings.library}/.keep".text = "";
          }
        )
      ];
    };

    nixos.beets = {
      config,
      lib,
      ...
    }: {
      # Create default listening interface at canonical locations in linux
      config = lib.mkIf config.services.nginx.enable {
        networking.hosts."127.0.0.1" = ["beets.localhost"];
        services.nginx.virtualHosts."beets.localhost" = {
          listen = [
            {
              addr = "127.0.0.1";
              port = 80;
            }
          ];
          locations."/".proxyPass = "http://127.0.0.1:8337";
        };
      };
    };
  };
}
