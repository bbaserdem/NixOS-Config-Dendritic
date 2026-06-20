# Derivation for static documentation of this repo
{
  pkgs,
  lib,
  inputs,
  ...
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "system-docs";
  version = "0-unstable";

  src = lib.sources.sourceByRegex inputs.self.outPath [
    "^book\\.toml$"
    "^docs(/.*)?$"
  ];

  nativeBuildInputs = [
    pkgs.mdbook
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    mdbook build . --dest-dir "$out"

    runHook postInstall
  '';
}
