# Flake development devshell
{inputs, ...}: {
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
          # Node for plugins and tooling
          nodejs-slim
          pnpm
          # Python for running scripts
          (
            python3.withPackages (p:
              with p; [
                pyyaml
              ])
          )
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
          ])
        );
    };
  };
}
