# Dev shell for edu-llm
{inputs, ...}: {
  # DevShell for working in work project with Lean
  perSystem = {pkgs, ...}: let
    # Minimal tex-live needed for this repo
    texlive-edu = pkgs.texliveBasic.withPackages (ps:
      with ps; [
        latex-bin # latex format + kpsewhich (kpathsea)
        standalone
        pgf # tikz.sty and the tikz/pgf libraries
        amsmath
        amsfonts # amssymb.sty and the Type 1 fonts dvisvgm traces
        dvisvgm
      ]);
    # Script to run dev server
    devScript = pkgs.writeShellApplication {
      name = "edullm-dev";
      runtimeInputs = with pkgs; [coreutils findutils lsof];
      text = ''
        # Detect latest run
        : "''${LOCAL_CLERK_ISSUER:?set in .envrc}" "''${LOCAL_CLERK_USER:?set in .envrc}"
        run="''${1:-$(find out -maxdepth 1 -type d -name '*-tutor-*' | sort | tail -1)}"
        [ -n "$run" ] || { echo "no run under out/; run: pnpm run:create --execute" >&2; exit 1; }
        # Kill holding ports
        for port in 3000 3001; do
          pid="$(lsof -nP -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null | head -1 || true)"
          if [ -n "$pid" ] ; then
            echo "stopping stale listener on :$port (pid $pid)" >&2
            kill -TERM -- "-$(ps -o pgid= -p "$pid" | tr -d ' ')" || true
            sleep 1
          fi
        done
        # Start server
        exec pnpm dev --attach "$run" \
          --origin http://127.0.0.1:3000 --eve-origin http://127.0.0.1:3001 \
          --issuer "$LOCAL_CLERK_ISSUER" --subject "$LOCAL_CLERK_USER" \
          --browser-origin http://127.0.0.1:3000
      '';
    };
  in {
    devShells.workEdu = pkgs.mkShell {
      packages = with pkgs;
        [
          # Project environment
          nodejs-slim_24 # Node.js without npm; we use pnpm
          pnpm
          uv # Python for running analysis
          postgresql_18 # We use postgres as db
          awscli2 # For AWS
          elan # Need lean for tikz-dsl typecheck for tikz code
          texlive-edu # Minimal TeX Live for packages/platform/tikz-compiler local.ts:
          devScript # Dev script for launching local server
          # Agentic tooling
          ripgrep
          shellcheck
          socat
          # MCPs needed
          playwright
          playwright-mcp
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
