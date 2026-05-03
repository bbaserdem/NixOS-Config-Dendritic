# Provision setup for this user
{inputs, ...}: {
  flake.modules = inputs.self.factory.syncthingUser {
    user = "batuhan";
    alias = "wolframite";
  };
}
