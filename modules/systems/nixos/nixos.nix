# Configuring OS defaults for nixos
{inputs, ...}: {
  den.aspects = {
    # Base aspect for all systems
    system = {host}: {
      nixos = {lib, ...}: {
        imports = with inputs.self.modules.nixos; [
          # Base modules that configure a nixos system
          nixos-console
          nixos-displayManager
          nixos-filesystem
          nixos-hardware
          nixos-keyboard
          nixos-locale
          nixos-networking
          nixos-root
          nixos-users
        ];
        config = {
          # Our default state version for our nixos systems
          system.stateVersion = lib.mkDefault "26.05";
          # Full computer name
          hardware.bluetooth.settings.General.Name = host.description;
        };
      };
    };
  };

  # TODO: Migrate this out into den later on
  flake.modules.nixos.nixos = {...}: {
    # Base imports; all nixos invocations should have these
    imports = with inputs.self.modules.nixos; [
      nix
      homeManager
      shell
      # Sub-module imports as well
      nixos-boot
      nixos-boot-local
      nixos-boot-grub
      nixos-boot-systemd
      nixos-console
      nixos-displayManager
      nixos-displayManager-local
      nixos-displayManager-gdm
      nixos-displayManager-plm
      nixos-displayManager-sddm
      nixos-displayManager-regreet
      nixos-filesystem
      inputs.self.modules.generic.filesystem
      inputs.disko.nixosModules.disko
      nixos-hardware
      nixos-keyboard
      nixos-locale
      nixos-networking
      nixos-root
      nixos-users
    ];
  };
}
