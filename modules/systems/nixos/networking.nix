# Networking tools to install to userspace
{inputs, ...}: {
  flake.modules.nixos.nixos-networking = {pkgs, ...}: {
    # Dispatch local LAN keys as trusted
    security.pki.certificates = [
      (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
    ];

    environment.systemPackages = with pkgs; [
      # Monitoring tools
      nethogs # Per-process network usage
      iftop # Network bandwidth monitoring
      net-tools # Connection monitoring
      tcpdump # Packet capture

      # Basic network utilities
      curl
      wget
      dig
      nmap
    ];
  };
}
