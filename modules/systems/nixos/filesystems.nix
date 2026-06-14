# Filesystem settings
{inputs, ...}: {
  flake.modules.nixos.nixos = {pkgs, ...}: {
    imports = [
      inputs.self.modules.generic.filesystems
      inputs.disko.nixosModules.disko
    ];

    # Enable FUSE
    programs.fuse = {
      enable = true;
      userAllowOther = true;
    };

    # Packages handling filesystems
    environment.systemPackages = with pkgs; [
      # Partition management
      parted
      ntfs3g
      gparted
      # Permissions
      acl
      # BTRFS tools
      btrfs-progs
      btrfs-assistant
      btrfs-heatmap
      snapper
      # Encrypted fuse filesystems
      gocryptfs
    ];
  };
}
