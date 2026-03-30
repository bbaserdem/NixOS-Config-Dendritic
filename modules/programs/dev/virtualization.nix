# Virtualization configuration
{...}: {
  flake.modules = {
    # Setup libvirt and virt-manager
    nixos.virtualization = {pkgs, ...}: {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;

      # Enable USB redirection
      virtualisation.spiceUSBRedirection.enable = true;

      # Install virtio-win drivers
      environment.systemPackages = with pkgs; [
        spice-gtk
        virtio-win
      ];
    };

    homeManager.virtualization = {
      lib,
      pkgs,
      ...
    }: {
      config = lib.mkMerge [
        # Set virt-manager to auto-connect to system
        (lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          dconf.settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = ["qemu:///system"];
              uris = ["qemu:///system"];
            };
          };
        })
      ];
    };
  };
}
