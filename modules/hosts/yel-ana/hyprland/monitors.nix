# Su-ana related settings for hyprdynamicmonitors
{lib, ...}: let
  confName = "hyprconfigs";
in {
  localConfig.hyprland.monitors = lib.mkOrder 500 [
    ''
      [profiles.yel-ana]
      config_file = "${confName}/yel-ana.tmpl"
      config_file_type = "template"
      [[profiles.yel-ana.conditions.required_monitors]]
      description = "BOE 0x0BCA"
      monitor_tag = "yel-ana"

      [profiles.yel-ana_present]
      config_file = "${confName}/yel-ana_present.tmpl"
      config_file_type = "template"
      [[profiles.yel-ana_present.conditions.required_monitors]]
      description = "BOE 0x0BCA"
      monitor_tag = "yel-ana"
      [[profiles.yel-ana_present.conditions.required_monitors]]
      description = "*"
      match_name_using_regex = true
      monitor_tag = "generic"

      [profiles.yel-ana_home-left]
      config_file = "${confName}/yel-ana_home-left.tmpl"
      config_file_type = "template"
      [[profiles.yel-ana_home-left.conditions.required_monitors]]
      description="BOE 0x0BCA"
      monitor_tag = "yel-ana"
      [[profiles.yel-ana_home-left.conditions.required_monitors]]
      description="Dell Inc. DELL U2723QE 945Q834"
      monitor_tag = "home-left"

      [profiles.yel-ana_home-right]
      config_file = "${confName}/yel-ana_home-right.tmpl"
      config_file_type = "template"
      [[profiles.yel-ana_home-right.conditions.required_monitors]]
      description="BOE 0x0BCA"
      monitor_tag = "yel-ana"
      [[profiles.yel-ana_home-right.conditions.required_monitors]]
      description="Dell Inc. DELL U3425WE B8KFV84"
      monitor_tag = "home-right"
    ''
  ];
  flake.modules.homeManager.hyprland = {
    pkgs,
    lib,
    ...
  }: let
  in {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.hyprdynamicmonitors = {
            extraFiles = {
              "hyprdynamicmonitors/${confName}/yel-ana.tmpl" = ./yel-ana.tmpl;
              "hyprdynamicmonitors/${confName}/yel-ana_present.tmpl" = ./yel-ana_present.tmpl;
              "hyprdynamicmonitors/${confName}/yel-ana_home-left.tmpl" = ./yel-ana_home-left.tmpl;
              "hyprdynamicmonitors/${confName}/yel-ana_home-right.tmpl" = ./yel-ana_home-right.tmpl;
            };
          };
        }
      )
    ];
  };
}
