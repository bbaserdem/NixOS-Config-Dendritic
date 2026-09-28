# Nixos; user account management
{
  inputs,
  den,
  ...
}: {
  # Aspect management
  den = {
    aspects.system = {
      provides.nixos = {
        includes = [
          den.aspects.system._.nixos._.accounts
        ];
        provides.accounts = {
          name = "system/nixos/accounts";
          nixos = {...}: {
            imports = [
              inputs.self.modules.nixos.nixos-accounts
            ];
          };
        };
      };
    };
  };

  # Module
  flake.modules.nixos.nixos-accounts = {...}: {
    key = "nixos-accounts#nixos";
    config = {
      # System bus service for account management
      services.accounts-daemon.enable = true;
    };
  };
}
