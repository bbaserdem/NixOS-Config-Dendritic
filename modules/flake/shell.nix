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
      ];
      shellHook = ''
        # Setup node
        export PATH="./node_modules/.bin:$PATH"
      '';
      # Setup nixd for this repo, not globally
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
  };
}
