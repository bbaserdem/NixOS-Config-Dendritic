{inputs, ...}: {
  # Create nixosConfig for our VM
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "umay";
}
