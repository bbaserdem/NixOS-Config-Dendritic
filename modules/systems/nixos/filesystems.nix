# Filesystem settings
{inputs, ...}: {
  flake.modules.nixos.nixos = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.self.modules.generic.filesystems
      inputs.disko.nixosModules.disko
    ];

    config = {
      # Enable FUSE
      programs.fuse = {
        enable = true;
        userAllowOther = true;
      };

      # File system support, disable zfs
      boot.supportedFilesystems.zfs = lib.mkForce false;

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
        cryptsetup
      ];
    };
  };
}
