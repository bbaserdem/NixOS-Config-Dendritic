# Flake-parts config for umay
# Not only we define system outputs here, we also define packages that build the qemu image
{
  inputs,
  pkgs,
  ...
}: let
  arch = "x86_64-linux";
in {
  flake = {
    # Create nixosConfig for our VM
    nixosConfigurations = inputs.self.lib.mkNixos {
      system = arch;
      name = "umay";
    };

    # Output us as a package
    packages."${arch}".umay = let
      lib = pkgs.lib;
      makeDiskImage = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix";
    in
      makeDiskImage {
        inherit pkgs lib;
        config = inputs.self.nixosConfigurations.umay.config;
        format = "qcow2";
        label = "nixos-umay";
        onlyNixStore = false;
        partitionTableType = "efi";
        installBootLoader = true;
        diskSize = "auto";
        copyChannel = false;
      };
  };
}
