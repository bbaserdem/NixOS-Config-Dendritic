# Configuring typescript
{...}: {
  # Node config
  flake.modules.homeManager.languages-ts = {config, ...}: {
    key = "languages-ts#homeManager";
    config = {
      # Define global node install directory
      # As long as pnpm is used, executables won't be duplicated
      home.sessionVariables = {
        "PNPM_HOME" = "${config.xdg.dataHome}/pnpm";
      };

      # Configure pnpm to put executables in .local/bin for global
      xdg.configFile."pnpm/rc".text = ''
        global-bin-dir=${config.home.homeDirectory}/.local/bin
        minimum-release-age=10080 # minutes
        block-exotic-subdeps=true
        trust-policy=no-downgrade
        strict-dep-builds=true
        only-built-dependencies=[]
      '';

      # Configure bun package manager with safety overrides
      # Don't install it though; it should be project-based
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
