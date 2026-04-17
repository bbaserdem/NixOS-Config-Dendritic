# Enabling mysql server
{...}: {
  flake.modules.nixos.mariadb = {...}: {
    services.mysql = {
      enable = true;
    };
  };
}
