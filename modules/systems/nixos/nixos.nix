# Configuring OS defaults for nixos
{inputs, ...}: {
  flake.modules.nixos.nixos = {...}: {
    # Base imports
    imports = with inputs.self.modules.nixos; [
      nix
      homeManager
    ];
  };
}
