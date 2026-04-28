# Factory function for provisioning folder sections for a given user
{lib, ...}: {
  flake.factory.syncthingUser = {
    user,
    alias ? user,
    ...
  }: {
  };
}
