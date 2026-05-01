# Factory function for provisioning folder sections for a given user
{lib, ...}: {
  flake.factory.syncthingUser = let
    # Helper function for capitalization
    capitalize = s:
      if s == ""
      then ""
      else (lib.toUpper (builtins.substring 0 1 s)) + (builtins.substring 1 (builtins.stringLength s) s);
  in
    {
      user,
      alias ? user,
      rootDir ? (capitalize alias),
      ...
    }: {
    };
}
