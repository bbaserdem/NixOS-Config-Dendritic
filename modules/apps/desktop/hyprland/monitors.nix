# Hyprland userspace utilities
{
  inputs,
  config,
  lib,
  ...
}: {
  options = {
    localConfig.hyprland.monitors = lib.mkOption {
      type = lib.types.listOf lib.types.lines;
      default = [];
      description = "Hyprdynamicmonitors monitor config fragments.";
    };
  };

  config = let
    cfgMonitorList = config.localConfig.hyprland.monitors;
  in {
    flake-file.inputs = {
      hyprdynamicmonitors = {
        url = "github:fiffeek/hyprdynamicmonitors";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };
    };

    flake.modules.homeManager.hyprland = {
      lib,
      pkgs,
      config,
      ...
    }: let
      outPath = "${config.xdg.configHome}/hypr/monitor.conf";
      hdmName = "hyprdynamicmonitors";
      confName = "hyprconfigs";
    in {
      imports = [
        inputs.hyprdynamicmonitors.homeManagerModules.default
      ];
      config = lib.mkMerge [
        (
          lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
            # Include us in binary list
            home.packages = [
              inputs.hyprdynamicmonitors.packages.${pkgs.stdenv.hostPlatform.system}.default
            ];

            # Enable hyprdynamicmonitors in hyprland
            wayland.windowManager.hyprland.settings.source = [
              "${outPath}"
            ];

            home.hyprdynamicmonitors = {
              extraFlags = ["--enable-lid-events"];
              extraFiles = {
                "${hdmName}/${confName}/generic.conf" = inputs.self + /assets/hyprdynamicmonitors.conf;
              };
              config = lib.mkBefore ''
                [general]
                destination = "${outPath}"
                debounce_time_ms = 500

                [notifications]
                timeout_ms = 2000

                [hot_reload_section]
                debounce_time_ms = 500

                [fallback_profile]
                config_file = "${confName}/generic.conf"
                config_file_type = "static"

                ${lib.concatStringsSep "\n" cfgMonitorList}
              '';
            };
          }
        )
      ];
    };
  };
}
