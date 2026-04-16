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

      # Configure pnpm to put executables in .local/bin
      xdg.configFile."pnpm/rc".text = ''
        global-bin-dir=${config.home.homeDirectory}/.local/bin
        minimum-release-age=10080 # minutes
        block-exotic-subdeps=true
        trust-policy=no-downgrade
        strict-dep-builds=true
        only-built-dependencies=[]
      '';

      # Configure npm as well
      home.file.".npmrc".text = ''
        min-release-age=7 # days
        ignore-scripts=true
      '';

      # Configure bun package manager with safety overrides
      programs = {
        bun = {
          enable = true;
          package = null;
          enableGitIntegration = false;
          settings = {
            install = {
              minimumReleaseAge = 604800; # One week in seconds
              lockfile = true;
              exact = true;
            };
          };
        };
      };
    };
  };
}
