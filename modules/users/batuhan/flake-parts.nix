# Initialize this user in flake-parts
{inputs, ...}: let
in {
  flake.modules = inputs.self.factory.user {
    username = "batuhan";
    isAdmin = true;
    isNix = true;
  };
}
