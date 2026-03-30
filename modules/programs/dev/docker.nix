# Configuring docker backends
{...}: {
  flake.modules = {
    nixos.docker = {pkgs, ...}: {
      # Setup podman for nixos
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          driver = "bridge";
        };
      };
      # Add podman-compose
      environment.systemPackages = with pkgs; [
        podman-compose
      ];
    };

    darwin.docker = {...}: {
      # Install through brew
      homebrew.casks = [
        "orbstack"
      ];
    };

    homeManager.docker = {...}: {
    };
  };
}
