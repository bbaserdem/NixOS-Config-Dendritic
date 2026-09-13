# Geoclue; network location
{inputs, ...}: {
  flake.modules.nixos.geoclue = {...}: {
    imports = with inputs.self.modules.nixos; [
      geoclue-settings
      geoclue-google
    ];
  };
}
