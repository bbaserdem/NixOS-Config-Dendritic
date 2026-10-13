{
  lib,
  pkgs,
  ...
}: let
  modelName = "parakeet-unified-en-0.6b";
  revision = "09e9060322d99c5f070010724786e6ee090fd51d";
  baseUrl = "https://huggingface.co/bobNight/${modelName}-onnx/resolve/${revision}";

  encoder = pkgs.fetchurl {
    name = "encoder.onnx";
    url = "${baseUrl}/encoder.onnx";
    hash = "sha256-UAg90LKvUDuH6o/Pn9fX3BXdoxMOQRMBfIs37QBBi6Q=";
  };

  encoderData = pkgs.fetchurl {
    name = "encoder.onnx.data";
    url = "${baseUrl}/encoder.onnx.data";
    hash = "sha256-wFSyky7hOqOe2EmCo5mCLzGTMR+2/Y4eIEVmciYUvYc=";
  };

  decoder = pkgs.fetchurl {
    name = "decoder_joint.onnx";
    url = "${baseUrl}/decoder_joint.onnx";
    hash = "sha256-ZGSMkZNepIGenDHqiiDwEdOxyWC+OGHLi8dN8CWc2Zg=";
  };

  tokenizer = pkgs.fetchurl {
    name = "tokenizer.model";
    url = "${baseUrl}/tokenizer.model";
    hash = "sha256-B9TlpjhApTqy1NEG0odHaBQ/s/vdR5OLORDS2gW/sKk=";
  };
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = modelName;
    version = "unstable-2026-04-09";
    dontUnpack = true;
    installPhase = ''
      runHook preInstall

      modelDir="$out/share/parakeet/${modelName}"
      mkdir -p "$modelDir"

      ln -s ${encoder}      "$modelDir/encoder.onnx"
      ln -s ${encoderData}  "$modelDir/encoder.onnx.data"
      ln -s ${decoder}      "$modelDir/decoder_joint.onnx"
      ln -s ${tokenizer}    "$modelDir/tokenizer.model"

      runHook postInstall
    '';
    meta = {
      description = "ONNX export of NVIDIA Parakeet Unified EN 0.6B";
      homepage = "https://huggingface.co/bobNight/${modelName}-onnx";
      license = lib.licenses.cc-by-40;
      platforms = lib.platforms.all;
    };
  }
