{pkgs, ...}: let
  py = pkgs.python3.pkgs;
in
  py.buildPythonPackage {
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

    build-system = [py.uv-build];
    dependencies = [
      py.mediafile
      py.mutagen
    ];
    nativeBuildInputs = [py.beets-minimal];
    nativeCheckInputs = [
      py.beets-minimal
      py.pytestCheckHook
    ];
    pythonImportsCheck = ["beetsplug.wolframite"];

    meta = {
      description = "Personal beets plugin";
      license = pkgs.lib.licenses.mit;
      platforms = py.beets-minimal.meta.platforms or pkgs.lib.platforms.all;
    };
  }
