# Provision networkmanagement for SBP
{config, ...}: {
  flake.modules = config.factory.networkmanagerUser {user = "sbp";};
}
