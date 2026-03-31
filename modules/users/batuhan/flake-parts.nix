# Initialize this user
{inputs, ...}: let
  userName = "batuhan";
in {
  flake.modules = inputs.self.factory.user {
    username = "${userName}";
    isAdmin = true;
    isNix = true;
  };
}
