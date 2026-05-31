# Apply gaming factory function
{config, ...}: {
  flake.modules = config.factory.steamUser {user = "wolframite";};
}
