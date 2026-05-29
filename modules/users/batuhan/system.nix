# System settings for this user
{inputs, ...}: let
  userName = "batuhan";
in {
  flake.modules = {
    # Darwin module settings
    darwin."${userName}" = {...}: {
      # Darwin modules to load for this user
      imports = with inputs.self.modules.darwin; [
      ];

      # System settings for user
      users.users."${userName}" = {
        description = "Batuha Baserdem";
      };
    };
  };
}
