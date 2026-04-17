# Configuring python package manager
{...}: {
  flake.modules.homeManager = {
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
