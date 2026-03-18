# Umay user
# Imports user definition for the umay host
{inputs, ...}: {
  flake.modules.nixos.ulgan = {...}: {
    # Enable our main user
    imports = with inputs.self.modules.nixos; [
      batuhan
    ];

    home-manager.users.batuhan = {
      # Modules to add to this users' home-manager config in this context
    };
  };
}
