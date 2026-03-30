# Networking tools to install to userspace
{...}: {
  flake.modules.nixos.networking = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Monitoring tools
      nethogs # Per-process network usage
      iftop # Network bandwidth monitoring
      nettools # Connection monitoring, <TODO> this is renamed to net-tools in unstable
      tcpdump # Packet capture

      # Basic network utilities
      curl
      wget
      dig
      nmap
    ];
  };
}
