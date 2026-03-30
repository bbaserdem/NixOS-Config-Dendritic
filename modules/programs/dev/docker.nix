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

    # Install orbstack on nix darwin
    homeManager.docker = {
      pkgs,
      lib,
      ...
    }: {
      config = lib.mkMerge [
        {}
        (lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin) {
          home.packages = with pkgs; [
            orbstack
          ];
        })
      ];
    };
  };
}
