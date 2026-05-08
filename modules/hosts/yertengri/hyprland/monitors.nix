# Yertengri related settings for hyprdynamicmonitors
{inputs, ...}: {
  flake.modules.homeManager.hyprland = {
    pkgs,
    lib,
    ...
  }: let
    confName = "hyprconfigs";
  in {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.hyprdynamicmonitors = {
            extraFiles = {
              "hyprdynamicmonitors/${confName}/home-left.conf" = ./home-left.conf;
              "hyprdynamicmonitors/${confName}/home-right.conf" = ./home-right.conf;
              "hyprdynamicmonitors/${confName}/home.conf" = ./home.conf;
            };
            config = ''

              [profiles.home-left]
              config_file = "${confName}/home-left.conf"
              config_file_type = "static"
              [[profiles.home-left.conditions.required_monitors]]
              description="Dell Inc. DELL U2723QE 945Q834"
              monitor_tag = "home-left"

              [profiles.home-right]
              config_file = "${confName}/home-right.conf"
              config_file_type = "static"
              [[profiles.home-right.conditions.required_monitors]]
              description="Dell Inc. DELL U3425WE B8KFV84"
              monitor_tag = "home-right"

              [profiles.home]
              config_file = "${confName}/home.conf"
              config_file_type = "static"
              [[profiles.home.conditions.required_monitors]]
              description="Dell Inc. DELL U2723QE 945Q834"
              monitor_tag = "home-left"
              [[profiles.home.conditions.required_monitors]]
              description="Dell Inc. DELL U3425WE B8KFV84"
              monitor_tag = "home-right"
            '';
          };
        }
      )
    ];
  };
}
