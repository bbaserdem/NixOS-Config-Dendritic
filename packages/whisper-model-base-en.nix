{
  lib,
  pkgs,
  ...
}: let
  modelName = "ggml-base.en";
  revision = "98aa99a0a9db05ae2342309f5096248665f7cba3";
  baseUrl = "https://huggingface.co/ggerganov/whisper.cpp/resolve";
  model = pkgs.fetchurl {
    name = modelName;
    url = "${baseUrl}/${revision}/${modelName}.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = "whisper-model-base-en";
    version = "1";

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      modelDir="$out/share/whisper"
      mkdir -p "$modelDir"

      ln -s ${model}        "$modelDir/${modelName}.bin"

      runHook postInstall
    '';
    meta = {
      description = "Whisper base (english) GGML model";
      homepage = "https://huggingface.co/ggerganov/whisper.cpp";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  }
