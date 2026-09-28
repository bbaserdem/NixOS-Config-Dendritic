# Filesystem settings
{
  inputs,
  den,
  ...
}: {
  den = {
    aspects.system = {
      provides.macos = {
        includes = [
          den.aspects.system._.macos._.filesystem
        ];
        provides.filesystem = {
          name = "system/macos/filesystem";
          darwin = {...}: {
            imports = [
              inputs.self.modules.generic.os-filesystem
              inputs.self.modules.darwin.macos-filesystem
            ];
          };
        };
      };
    };
  };

  # Modules
  flake.modules.darwin.macos-filesystem = {pkgs, ...}: {
    key = "macos-filesystem#darwin";
    config = {
      # Additionale support
      homebrew = {
        casks = [
          "macfuse"
        ];
      };

      # Install fuse filesystem packages
      environment.systemPackages = with pkgs; [
        gocryptfs
        ext4fuse
      ];
    };
  };
}
