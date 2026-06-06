{inputs, ...}: {
  # DevShell for producing my LaTeX packages
  perSystem = {pkgs, ...}: {
    devShells.latex = pkgs.mkShell {
      packages = with pkgs; [
        # Node tooling
        nodejs-slim
        pnpm
        # Python tooling
        uv
        # Agentic tooling
        ripgrep
        (
          texlive.combine {
            inherit
              (texlive)
              scheme-basic
              collection-bibtexextra
              collection-binextra
              collection-context
              collection-fontsextra
              collection-fontsrecommended
              collection-fontutils
              collection-formatsextra
              collection-games
              collection-langenglish
              collection-langgreek
              collection-langother
              collection-latex
              collection-latexextra
              collection-latexrecommended
              collection-luatex
              collection-mathscience
              collection-metapost
              collection-pictures
              collection-plaingeneric
              collection-pstricks
              collection-publishers
              collection-xetex
              algorithms
              cleveref
              latexmk
              cormorantgaramond
              xcharter
              tree-dvips
              maths-symbols
              unicode-math
              nunito
              archivo
              ;
          }
        )
      ];
      shellHook = ''
        # Node should be set in .envrc
      '';
      # Setup nixd for this repo, not globally
      NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };
  };
}
