{
  lib,
  buildPythonPackage,
  uv-build,
  mediafile,
  mutagen,
  beets-minimal,
  pytestCheckHook,
}:
buildPythonPackage {
  pname = "beets-wolframite";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  # nixpkgs' python package attribute/distribution is commonly patched to uv-build
  # But upstream uv docs use uv_build
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.10,<0.12" "uv-build"
  '';

  build-system = [
    uv-build
  ];

  dependencies = [
    mediafile
    mutagen
  ];

  nativeBuildInputs = [
    beets-minimal
  ];

  nativeCheckInputs = [
    beets-minimal
    pytestCheckHook
  ];

  pythonImportsCheck = [
    "beetsplug.wolframite"
  ];

  meta = {
    description = "Personal beets plugin";
    license = lib.licenses.mit;
    inherit (beets-minimal.meta) platforms;
  };
}
