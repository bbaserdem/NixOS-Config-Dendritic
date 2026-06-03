# Networking tools to install to userspace
{...}: {
  flake.modules.nixos.nixos = {pkgs, ...}: {
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
