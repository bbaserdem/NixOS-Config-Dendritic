{pkgs, ...}: let
  py = pkgs.python3.pkgs;
in
  py.buildPythonApplication {
    pname = "audman";
    version = "0.1.0";
    pyproject = true;

    src = ./.;

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail "uv_build>=0.10,<0.12" "uv-build"
    '';

    build-system = [py.uv-build];

    dependencies = [
      py.typer
    ];

    makeWrapperArgs = [
      "--prefix PATH : ${pkgs.lib.makeBinPath [pkgs.ffmpeg]}"
    ];

    nativeCheckInputs = [
      py.pytestCheckHook
    ];

    pythonImportsCheck = ["audman"];

    meta = {
      description = "Personal audio conversion manager";
      license = pkgs.lib.licenses.mit;
      mainProgram = "audman";
    };
  }
