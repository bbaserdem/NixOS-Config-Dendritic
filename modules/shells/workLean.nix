{inputs, ...}: {
  # DevShell for working in work project with Lean
  perSystem = {pkgs, ...}: {
    devShells.workLean = pkgs.mkShell {
      packages = with pkgs;
        [
          # Get python for running scripts (BMad)
          (
            python3.withPackages (p:
              with p; [
                pyyaml
                playwright
              ])
          )
          # Node.js for claude and codex
          nodejs-slim
          pnpm
          # Project environment
          bun
          elan
          postgresql
          # Tooling for agents
          ripgrep
          shellcheck
          socat
          playwright
          playwright-test
          # Doc rendering
          mdbook
          mdbook-mermaid
          mdbook-d2
          d2
        ]
        ++ (
          lib.optionals (pkgs.stdenv.hostPlatform.isLinux) (with pkgs; [
            bubblewrap
          ])
        );
      shellHook = ''
        # Node should be set in .envrc
      '';
      # Setup nixd for this repo, not globally
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
  };
}
