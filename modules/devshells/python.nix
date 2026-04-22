# DevShell for python development
{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    devShells.python = pkgs.mkShell {
      packages = with pkgs;
        [
          # Python projects use uv tooling for python environment
          uv
          # Node.js for claude and codex
          nodejs-slim
          pnpm
          # Tooling for agents
          ripgrep
          shellcheck
          nixd
          bash-language-server
          socat
          # Doc rendering
          mdbook
          mdbook-mermaid
        ]
        ++ (
          lib.optionals (pkgs.stdenv.hostPlatform.isLinux) (with pkgs; [
            bubblewrap
          ])
        );
      shellHook = ''
        # Setup Python via uv
        export UV_PYTHON_PREFERENCE=only-managed

        # Sync dependencies if pyproject.toml exists
        if [ -f "pyproject.toml" ]; then
          # Create venv if it doesn't exist
          if [ ! -d ".venv" ]; then
            echo "Creating Python virtual environment with uv..."
            uv venv
          fi

          # Sync project deps
          uv sync --all-extras
        fi
      '';
    };
  };
}
