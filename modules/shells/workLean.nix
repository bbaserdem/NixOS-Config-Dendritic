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
        # Project environment
        bun
        lean4
        # Tooling for agents
        ripgrep
        shellcheck
        # Doc rendering
        mdbook
        mdbook-mermaid
      ];
      shellHook = ''
        # Node should be set in .envrc
      '';
      # Setup nixd for this repo, not globally
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
  };
}
