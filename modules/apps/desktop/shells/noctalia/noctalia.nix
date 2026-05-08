# Noctalia, desktop shell
{...}: {
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  flake.modules.homeManager.noctalia = {
    lib,
    pkgs,
    ...
  }: {
    config = lib.mkMerge [
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
        }
      )
    ];
  };
}
