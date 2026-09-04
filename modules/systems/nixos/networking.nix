# Networking tools to install to userspace
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.system = {
      # This provides already included inside the system aspect
      provides.networking = {
        # Firewall port opening from quirk
        nixos = {
          local-ports,
          lib,
          ...
        }: {
          imports = [
            inputs.self.modules.nixos.nixos-networking
          ];
          config = {
            networking.firewall = {
              # Load all port specifications from
              allowedTCPPorts =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["tcp" "all"])
                |> builtins.filter (p: p ? port)
                |> builtins.map (p: p.port)
                |> lib.lists.unique;
              allowedTCPPortRanges =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["tcp" "all"])
                |> builtins.filter (p: ((p ? from) && (p ? to)))
                |> builtins.map (p: {inherit (p) from to;})
                |> lib.lists.unique;
              allowedUDPPorts =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["udp" "all"])
                |> builtins.filter (p: p ? port)
                |> builtins.map (p: p.port)
                |> lib.lists.unique;
              allowedUDPPortRanges =
                local-ports
                |> builtins.filter (p: builtins.elem p.proto ["udp" "all"])
                |> builtins.filter (p: ((p ? from) && (p ? to)))
                |> builtins.map (p: {inherit (p) from to;})
                |> lib.lists.unique;
            };
          };
        };
      };
    };
  };

  # Networking module
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
