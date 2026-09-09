# Dev shell for edu-llm
{inputs, ...}: {
  # DevShell for working in work project with Lean
  perSystem = {pkgs, ...}: {
    devShells.workEdu = pkgs.mkShell {
      packages = with pkgs;
        [
          # Node.js for claude and codex
          nodejs-slim_24
          pnpm
          # Project environment
          postgresql_18
          awscli2
          (
            # Minimal TeX Live for packages/platform/tikz-compiler local.ts:
            #   latex, dvisvgm, kpsewhich on PATH, plus standalone.cls, tikz.sty,
            #   amsmath.sty, amssymb.sty and the arrows.meta/calc/positioning/angles/quotes
            #   libraries. dvisvgm runs with --no-fonts --no-mktexmf --no-specials=ps, so
            #   glyphs become paths from the Type 1 CM/AMS fonts in amsfonts; no
            #   ghostscript, no metafont. If a kpsewhich probe ever fails, swap
            #   texliveInfraOnly for texliveBasic before adding packages by hand.
            texliveBasic.withPackages (ps:
              with ps; [
                latex-bin # latex format + kpsewhich (kpathsea)
                standalone
                pgf # tikz.sty and the tikz/pgf libraries
                amsmath
                amsfonts # amssymb.sty and the Type 1 fonts dvisvgm traces
                dvisvgm
              ])
          )
          # Tooling for agents
          ripgrep
          shellcheck
          socat
          # MCP
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
