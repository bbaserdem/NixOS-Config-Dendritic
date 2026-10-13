{
  lib,
  pkgs,
  ...
}: let
  modelName = "ggml-large-v3-turbo";
  revision = "98aa99a0a9db05ae2342309f5096248665f7cba3";
  baseUrl = "https://huggingface.co/ggerganov/whisper.cpp/resolve";
  model = pkgs.fetchurl {
    name = modelName;
    url = "${baseUrl}/${revision}/${modelName}.bin";
    hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
  };
in
  pkgs.stdenvNoCC.mkDerivation {
    pname = "whisper-model-large-v3-turbo";
    version = "3-turbo";

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
      description = "Whisper large-v3-turbo GGML model";
      homepage = "https://huggingface.co/ggerganov/whisper.cpp";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  }
