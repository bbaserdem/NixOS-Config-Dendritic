{inputs, ...}: {
  # DevShell for this flake
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      # Default dev shell to do development work
      packages = with pkgs; [
        # Python tooling
        uv
        # Node.js for any JS tooling needs
        nodejs-slim
        pnpm
        # LSPs for coding agents
        nixd
        bash-language-server
        # Tooling for agents
        ripgrep
        # Linters
        shellcheck
        # Renderer for docs
        mdbook
        mdbook-mermaid
      ];
      shellHook = ''
        # Setup node
        export PATH="./node_modules/.bin:$PATH"

        # Setup Python via uv
        export UV_PYTHON_PREFERENCE=only-managed

        # Create venv if it doesn't exist
        if [ ! -d ".venv" ]; then
          echo "Creating Python virtual environment with uv..."
          uv venv
        fi

        # Activate the virtual environment
        source .venv/bin/activate

        # Sync dependencies if pyproject.toml exists
        if [ -f "pyproject.toml" ]; then
          echo "Syncing Python dependencies..."
          uv sync --all-extras
        fi
      '';
      # Setup nixd for this repo, not globally
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
  };
}
