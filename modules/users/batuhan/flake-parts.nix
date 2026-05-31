# Initialize this user
{config, ...}: let
  userName = "batuhan";
in {
  flake.modules = config.factory.user {
    username = "${userName}";
    isAdmin = true;
    isNix = true;
  };
}
