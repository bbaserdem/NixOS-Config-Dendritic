# Tuned, laptop power optimization/management
{...}: {
  flake.modules.nixos.tuned = {...}: {
    services.tuned = {
      enable = true;
      ppdSupport = true;
    };
  };
}
