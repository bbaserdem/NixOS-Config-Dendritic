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

      # Configure package manager with safety overrides
      programs = {
        bun = {
          enable = true;
          package = null;
          enableGitIntegration = false;
          settings = {
            install = {
              minimumReleaseAge = 604800; # One week in seconds
            };
          };
        };
      };
    };

    # Python config
    python = {...}: {
      # Set global configuration for uv
      programs.uv = {
        enable = true;
        package = null;
        settings = {
          exclude-newer = "1 week";
        };
      };
    };
  };
}
