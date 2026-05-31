# Initialize this user
{config, ...}: let
  userName = "wolframite";
in {
  flake.modules = config.factory.user {
    username = "${userName}";
    isAdmin = true;
    isNix = true;
  };
}
