{
  lib,
  inputs,
  ...
}: {
  # Create nixosConfig for our VM
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "umay";

  # Export our image as a package
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    packages = lib.mkMerge [
      {}
      (
        lib.mkIf
        (system == "x86_64-linux")
        {
          umay-vm = let
            lib = pkgs.lib;
            makeDiskImage = import "${inputs.nixpkgs}/nixos/lib/make-disk-image.nix";
          in
            makeDiskImage {
              inherit pkgs lib;
              config = inputs.self.nixosConfigurations.umay.config;
              format = "qcow2";
              onlyNixStore = false;
              partitionTableType = "efi";
              installBootLoader = true;
              diskSize = "auto";
              copyChannel = false;
            };
        }
      )
    ];
  };
}
