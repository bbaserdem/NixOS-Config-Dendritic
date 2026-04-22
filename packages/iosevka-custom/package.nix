{pkgs, ...}: let
  # Load and parse the TOML file
  tomlConfig = builtins.fromTOML (builtins.readFile ./iosevka.toml);

  # Extract the specific build plan.
  # This matches the [buildPlans.IosevkaCustom] header in your file.
  plan = tomlConfig.buildPlans.IosevkaCustom;
in
  pkgs.iosevka.override {
    set = "Custom";
    privateBuildPlan = plan;
  }
