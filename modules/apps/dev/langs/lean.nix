# Configuring elan, lean package manager
{...}: {
  flake.modules.homeManager = {
    # Lean config
    lean = {config, ...}: let
      elanHome = ".local/share/elan";
    in {
      # Define global lean install directory
      home.sessionVariables = {
        "ELAN_HOME" = "${config.home.homeDirectory}/${elanHome}";
      };
    };
  };
}
