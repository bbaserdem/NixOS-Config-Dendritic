{inputs, ...}: {
  flake.modules = {
    # Nixos module settings
    nixos.batuhan = {...}: {
      # Nixos modules to load with this user enabled
      imports = with inputs.self.modules.nixos; [
      ];

      # Add this user to additional groups
      users.users.batuhan = {
        extraGroups = [
          "docker"
          "libvirtd"
          "libvirtd-qemu"
        ];
      };
    };

    # Darwin module settings
    darwin.batuhan = {...}: {
      # Darwin modules to load for this user
      imports = with inputs.self.modules.darwin; [
      ];
    };

    # Hmoe manager settings
    homeManager.batuhan = {...}: {
      home.stateVersion = "25.05";
    };
  };
}
