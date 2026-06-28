# Nixos; vulkan tooling
{...}: {
  # Common hardware configuration to dispatch
  flake.modules.nixos.nixos-vulkan = {pkgs, ...}: {
    config = {
      # User tooling
      environment.systemPackages = with pkgs; [
        vulkan-tools
      ];
    };
  };
}
