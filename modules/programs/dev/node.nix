# Configuring node package manager
{...}: {
  flake.modules.homeManager = {
    # Node config
    node = {config, ...}: {
      # Define global node install directory
      # As long as pnpm is used, execs won't be duplicated
      home.sessionVariables = {
        "PNPM_HOME" = "${config.xdg.dataHome}/pnpm";
      };
    };

    # Python config
    python = {...}: {
      # Enable uv to be able to set global configuration
      programs.uv = {
        enable = true;
        settings = {
          exclude-newer = "1 week";
        };
      };
    };
  };
}
