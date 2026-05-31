# Provision setup for this user
{config, ...}: {
  flake.modules = config.factory.networkmanagerUser {user = "wolframite";};
}
