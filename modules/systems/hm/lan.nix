# Dispatch certificate to home
{inputs, ...}: {
  flake.modules.homeManager.hm = {...}: {
    # Dispatch local LAN keys for manual import
    xdg.dataFile."certs/home-lan-ca.crt" = {
      source = inputs.self + /assets/home-lan-ca.crt;
    };
  };
}
