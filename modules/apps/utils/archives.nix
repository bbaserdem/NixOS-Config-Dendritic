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
      rzip
      gnutar
      xz
      zstd
    ]);
  in {
    # Include to homeManager
    generic.archives = {pkgs, ...}: {
      environment.systemPackages = archivePkgs pkgs;
    };

    # Install to user
    homeManager.archives = {pkgs, ...}: {
      home.packages = archivePkgs pkgs;
    };
  };
}
