# Flake development devshell
{inputs, ...}: {
  # Multi-boot system
  flake-file.inputs = {
    multios-usb = {
      url = "github:Mexit/MultiOS-USB";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs-unstable";
      };
    };
  };

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs;
        [
          # Flake tooling
          dconf2nix # Extract gnome settings
          update-nix-fetchgit
          nix-prefetch-github
          nixos-anywhere
          # Encryption
          sops
          ssh-to-age
          gnupg
          age
          mkpasswd
          # Node for plugins and tooling
          nodejs-slim
          pnpm
          # Python for running scripts and building local packages
          (
            python3.withPackages (p:
              with p; [
                pyyaml
                beets-minimal
                mediafile
                mutagen
                pytest
                typer
              ])
          )
          uv
          ruff
          ty
          # Tooling for agents
          ripgrep
          shellcheck
          socat
          # Doc rendering
          mdbook
          mdbook-mermaid
        ]
        ++ (
          lib.optionals (pkgs.stdenv.hostPlatform.isLinux) (with pkgs; [
            # Sandboxing for agents
            bubblewrap
            # MultiOS-USB binary creation
            inputs.multios-usb.packages.${pkgs.stdenv.hostPlatform.system}.default
          ])
        );
    };
  };
}
