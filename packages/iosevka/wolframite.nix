{pkgs, ...}: let
  # Load and parse the TOML file
  tomlConfig = builtins.fromTOML (builtins.readFile ./wolframite.toml);

  # Extract the specific build plan.
  # This matches the [buildPlans.Iosevka<NAME>] header in your file.
  plan = tomlConfig.buildPlans.IosevkaWolframite;
in
  pkgs.iosevka.override {
    set = "Wolframite";
    privateBuildPlan = plan;
  }
