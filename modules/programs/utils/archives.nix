# Archiving utilities
{inputs, ...}: {
  flake.modules = let
    archivePkgs = pkgs: (with pkgs; [
      patool
      zip
      bzip2
      bzip3
      p7zip
      ncompress
      gzip
      rar
      unrar
      rzip
      gnutar
      xz
      zstd
    ]);
  in {
    # Include to homeManager
    generic.archives = {pkgs, ...}: {
      home-manager.sharedModules = [
        inputs.self.modules.homeManager.archives
      ];
      environment.systemPackages = archivePkgs pkgs;
    };

    # Modules to install archiving tools
    nixos.archives = {...}: {
      imports = [inputs.self.modules.generic.archives];
    };
    darwin.archives = {...}: {
      imports = [inputs.self.modules.generic.archives];
    };

    # Install to user
    homeManager.archives = {pkgs, ...}: {
      home.packages = archivePkgs pkgs;
    };
  };
}
