# Flake-parts config for umay
# Not only we define system outputs here, we also define packages that build the qemu image
{
  inputs,
  pkgs,
  ...
}: let
  arch = "x86_64-linux";
  host = "umay";
in {
  flake = {
    # Create nixosConfig for our VM
    nixosConfigurations = inputs.self.lib.mkNixos {
      system = arch;
      name = host;
    };

    # Output us as a package to be created by other linux hosts, platform specific
    packages."${arch}"."${host}" = let
      lib = pkgs.lib;
      makeDiskImage = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix";
    in
      makeDiskImage {
        inherit pkgs lib;
        config = inputs.self.nixosConfigurations."${host}".config;
        name = host;
        baseName = "${host}-nixos-vm";
        format = "qcow2";
        onlyNixStore = false;
        partitionTableType = "efi";
        installBootLoader = true;
        diskSize = "auto";
        additionalSpace = "512M";
        copyChannel = false;
      };
  };
}
