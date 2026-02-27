{
  lib,
  self,
  ...
}: let
  username = "batuhan";
in {
  flake.modules = lib.mkMerge [
    # Factory function user creation
    (self.factory.user {
      inherit username;
      isAdmin = true;
      isNix = true;
    })
    # Additional modules to load with this user
    {
      nixos."${username}" = {...}: {
        imports = with self.modules.nixos; [
          # Additional nixos modules to load with this user enabled
        ];
        users.users."${username}" = {
          # Add this user to additional groups
          extraGroups = [
            "networkmanager"
            "docker"
            "libvirtd"
            "libvirtd-qemu"
          ];
        };
      };

      darwin."${username}" = {...}: {
        imports = with self.modules.darwin; [
          # Additional darwin modules to load
        ];
      };

      homeManager."${username}" = {pkgs, ...}: {
        imports = with self.modules.homeManager; [
          # Additional home-manager modules to load with this user enabled
        ];
        home.stateVersion = "25.05";
        home.packages = with pkgs; [
          # Additional packages to load to this users' environment
        ];
      };
    }
  ];
}
