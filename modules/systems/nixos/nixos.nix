# Configuring OS defaults for nixos
{inputs, ...}: {
  flake.modules.nixos.nixos = {...}: {
    # Base imports; all nixos invocations should have these
    imports = with inputs.self.modules.nixos; [
      nix
      homeManager
      shell
    ];
  };
}
