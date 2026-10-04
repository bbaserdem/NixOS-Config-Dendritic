# Metadata on this flake
{lib, ...}: {
  # Options definitions for local metadata
  options = {
    nixpkgs = {
      # Version for tooling
      version = lib.mkOption {
        type = lib.types.str;
        description = "Nix tooling version";
      };
      # Overlays to apply
      overlays = lib.mkOption {
        type = lib.types.listOf lib.types.raw;
        default = [];
        description = "List of overlays to apply to nixpkgs invocations";
      };
      config = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        description = "Configuration to be applied to nixpkgs invocations";
      };
    };
  };

  config = {
    # Nixpkgs version to use
    nixpkgs.version = "26.05";

    # Nix formatter for this flake
    perSystem = {pkgs, ...}: {
      formatter = pkgs.alejandra;
    };

    # Enable debug mode
    debug = true;
  };
}
