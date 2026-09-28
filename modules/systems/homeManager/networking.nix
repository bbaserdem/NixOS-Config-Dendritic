# Dispatch certificate so users can use it individually
{inputs, ...}: {
  flake.modules.homeManager.hm-networking = {...}: {
    key = "hm-networking#homeManager";
    config = {
      # Dispatch local LAN keys for manual import
      xdg.dataFile."certs/home-lan-ca.crt" = {
        source = inputs.self + /assets/home-lan-ca.crt;
      };
    };
  };
}
