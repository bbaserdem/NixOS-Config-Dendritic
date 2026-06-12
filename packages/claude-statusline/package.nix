{pkgs, ...}:
pkgs.stdenv.mkDerivation (
  let
    deps = with pkgs; [
      bash
      coreutils
      jq
      git
      gawk
    ];
  in {
    pname = "claude-statusline";
    version = "1.0.0";

    # Point to the directory containing your .sh files
    src = ./.;

    nativeBuildInputs = [pkgs.makeWrapper];

    # Dependencies needed by the scripts
    buildInputs = deps;

    installPhase = ''
      mkdir -p $out/bin

      for script in *.sh; do
        # Prefix claude-statusbar- and remove .sh extension for the executable name
        targetName="claude-statusbar-''${script%.sh}"
        cp "$script" "$out/bin/$targetName"
        chmod +x "$out/bin/$targetName"
      done
    '';

    postFixup = ''
      # 1. Fix #!/bin/bash to point to the Nix store bash
      patchShebangs $out/bin

      # 2. Wrap every script so they have their dependencies
      # AND each other (via $out/bin) in their PATH.
      for bin in $out/bin/*; do
        wrapProgram "$bin" \
          --prefix PATH : "${pkgs.lib.makeBinPath deps}:$out/bin"
      done
    '';
  }
)
