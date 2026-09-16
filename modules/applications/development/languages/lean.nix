# Configuring elan, lean package manager
{...}: {
  # Lean config
  flake.modules.homeManager.languages-lean = {config, ...}: {
    key = "languages-lean#homeManager";
    config = {
      # Define global lean install directory
      home.sessionVariables = {
        "ELAN_HOME" = "${config.xdg.dataHome or "${config.home.homeDirectory}/.local/share"}/elan";
      };
    };
  };
}
