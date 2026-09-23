# Configuring OpenCode; provider
{...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    config,
    ...
  }: {
    config = {
      programs.opencode = {
        settings = {
        };
      };
    };
  };
}
