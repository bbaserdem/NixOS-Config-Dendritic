# Beets web-ui
{...}: {
  flake.modules = {
    # Beets nixos module registers the default port 8337 with nginx;
    # Only need to bind to that interface, and enable systemd service
    homeManager.wolframite = {
      config,
      lib,
      pkgs,
      ...
    }: let
    in {
      config = lib.mkMerge [
        {
          # Configuration in beets
          programs.beets.settings = {
            plugins = [
              "web"
            ];
            web = {
              host = "127.0.0.1";
              port = 8337;
              readonly = true;
              reverse_proxy = true;
              include_paths = false;
            };
          };
        }
        (
          # Enable systemd unit in linux, and we have beets
          lib.mkIf (
            (pkgs.stdenv.hostPlatform.isLinux)
            && (config.programs.beets.enable)
          ) {
            systemd.user.services.beets-web.Install.WantedBy = ["default.target"];
          }
        )
      ];
    };
  };
}
