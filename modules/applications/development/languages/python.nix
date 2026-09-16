# Configuring python
{...}: {
  # Node config
  flake.modules.homeManager.languages-python = {config, ...}: {
    key = "languages-python#homeManager";
    config = {
      # Set global configuration for uv without installing it
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
