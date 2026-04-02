{inputs, ...}: {
  # DevShell for working in work project with Lean
  perSystem = {pkgs, ...}: {
    devShells.workLean = pkgs.mkShell {
      packages = with pkgs; [
        # Get python for running scripts (BMad)
        (
          python3.withPackages (p:
            with p; [
              pyyaml
            ])
        )
        # Node.js for claude and codex
        nodejs-slim
        pnpm
        # Project environment
        bun
        lean4
        postgresql
        # Tooling for agents
        ripgrep
        shellcheck
        # Doc rendering
        mdbook
        mdbook-mermaid
        mdbook-d2
        d2
      ];
      shellHook = ''
        # Node should be set in .envrc
      '';
      # Setup nixd for this repo, not globally
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
  };
}
