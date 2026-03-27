# Archiving utilities
{...}: {
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
    # Modules to install archiving tools
    nixos.archives = {pkgs, ...}: {
      environment.systemPackages = archivePkgs pkgs;
    };
    homeManager.archives = {pkgs, ...}: {
      home.packages = archivePkgs pkgs;
    };
  };
}
