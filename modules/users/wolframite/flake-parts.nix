# Initialize this user
{inputs, ...}: let
  userName = "wolframite";
in {
  flake.modules = inputs.self.factory.user {
    username = "${userName}";
    isAdmin = true;
    isNix = true;
  };
}
