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
  in {
    devShells.workEdu = pkgs.mkShell {
      packages = with pkgs;
        [
          # Secret management; bug hurts build
          # TODO: undo the override once this is fixed
          (
            unstable.secretspec.overrideAttrs (old: {
              checkFlags =
                (old.checkFlags or [])
                ++ [
                  "--skip=configure_refuses_to_replace_an_unmanaged_helper"
                  "--skip=unconfigure_refuses_to_remove_an_edited_managed_helper"
                ];
            })
          )
          # Typescript
          nodejs-slim_24 # Node.js without npm; we use pnpm
          pnpm
          # Python
          uv # Python for running analysis
          # AWS
          awscli2 # For AWS access
          ssm-session-manager-plugin # Sessionmanager plugin
          # Postgres
          postgresql_18 # We use postgres as db
          # TikZ
          elan # Need lean for tikz-dsl typecheck for tikz code
          texlive-edu # Minimal TeX Live for packages/platform/tikz-compiler local.ts:
          # Tooling for agents
          ripgrep
          shellcheck
          socat
          curl
          jq
          yq
          # Documentation
          mdbook
          mdbook-mermaid
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
