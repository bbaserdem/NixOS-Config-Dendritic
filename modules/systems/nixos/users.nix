# Nixos; general users related settings.
{...}: {
  flake.modules.nixos.nixos-users = {...}: {
    # System bus service for account management
    services.accounts-daemon.enable = true;
  };
}
