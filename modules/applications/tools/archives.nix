# Archiving utilities
{...}: {
  flake.modules = let
    # Common function that returns the package set; to set to both modules
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
    generic.tools-archive = {pkgs, ...}: {
      key = "tools-archive#generic";
      config = {
        environment.systemPackages = archivePkgs pkgs;
      };
    };

    # Install to user
    homeManager.tools-archive = {pkgs, ...}: {
      key = "tools-archive#homeManager";
      config = {
        home.packages = archivePkgs pkgs;
      };
    };
  };
}
