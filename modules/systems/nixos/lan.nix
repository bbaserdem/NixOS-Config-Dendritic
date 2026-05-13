# Configuring the local lan of nixos systems
{inputs, ...}: {
  flake.modules.nixos.nixos = {...}: {
    # Dispatch local LAN keys as trusted
    security.pki.certificates = [
      (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
    ];
  };
}
