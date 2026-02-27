{inputs, ...}: {
  flake.modules.nixos.umay = {...}: {
    imports = with inputs.self.modules.nixos; [
    ];
  };
}
