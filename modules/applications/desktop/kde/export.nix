# Script to dump current settings
{inputs, ...}: {
  # Inject package to linux package sets directly since we are vendor-bound
  perSystem = {
    lib,
    pkgs,
    system,
    ...
  }: {
    packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      plasmaDump = pkgs.writeShellApplication {
        name = "plasmaDump";
        runtimeInputs = [
          inputs.plasma-manager.packages.${system}.rc2nix
          pkgs.coreutils
        ];

        text = ''
          set -euo pipefail

          out_dir="$PWD"
          rc2nix_args=()

          while [ "$#" -gt 0 ]; do
            case "$1" in
              --output-dir)
                if [ "$#" -lt 2 ] || [ -z "$2" ]; then
                  printf 'error: --output-dir requires a directory\n' >&2
                  exit 2
                fi
                out_dir="$2"
                shift 2
                ;;
              --output-dir=*)
                out_dir="''${1#--output-dir=}"
                if [ -z "$out_dir" ]; then
                  printf 'error: --output-dir cannot be empty\n' >&2
                  exit 2
                fi
                shift
                ;;
              --)
                shift
                rc2nix_args+=("$@")
                break
                ;;
              *)
                rc2nix_args+=("$1")
                shift
                ;;
            esac
          done

          mkdir -p "$out_dir"

          timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
          out="$out_dir/plasma-dump_$timestamp.nix"

          rc2nix "''${rc2nix_args[@]}" > "$out"

          printf 'Settings export created at: %s\n' "$(realpath "$out")"
        '';
      };
    };
  };
}
