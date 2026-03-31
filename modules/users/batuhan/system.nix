# System settings for this user
{inputs, ...}: let
  userName = "batuhan";
in {
  flake.modules = {
    # Modules population for system settings

    # Nixos module settings
    nixos."${userName}" = {...}: {
      # Nixos modules to load with this user enabled
      imports = with inputs.self.modules.nixos; [
      ];

      # System settings for user
      users.users."${userName}" = {
        description = "Batuhan Baserdem";
        # Add this user to theese additional groups
        extraGroups = [
          "docker"
          "libvirtd"
          "libvirtd-qemu"
        ];
      };
    };

    # Darwin module settings
    darwin."${userName}" = {...}: {
      # Darwin modules to load for this user
      imports = with inputs.self.modules.darwin; [
      ];

      # System settings for user
      users.users."${userName}" = {
        description = "Batuhan Baserdem";
      };
    };

    # Home manager settings
    homeManager."${userName}" = {...}: {
      # Home manager modules to load for this user
      imports = with inputs.self.modules.homeManager; [
      ];
    };
  };
}
