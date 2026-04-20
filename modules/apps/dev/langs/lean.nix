# Configuring elan, lean package manager
{...}: {
  flake.modules.homeManager = {
    # Lean config
    lean = {config, ...}: {
      # Define global lean install directory
      home.sessionVariables = {
        "ELAN_HOME" = "${config.xdg.dataHome}/lean";
      };

      # Lean puts executables in ELAN_HOME/bin, symlink this to .local/bin
      home.file."${config.home.homeDirectory}/.elan/bin" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/bin";
      };
    };
  };
}
