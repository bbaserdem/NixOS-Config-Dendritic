{pkgs, ...}:
pkgs.python3Packages.buildPythonApplication (
  finalAttrs: {
    pname = "sidepulse";
    version = "0.0.0+20260914.6744439";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "inteliwear";
      repo = "sidepulse";
      rev = "6744439d8e82fa9beb727cfd06126686ecd68951";
      hash = "sha256-Vl+Bp35S1qRKhHchbeODPQphqmwLbVJdDN40aIpatYg=";
    };

    # The source archive has no VCS metadata for setuptools-scm.
    env.SETUPTOOLS_SCM_PRETEND_VERSION = finalAttrs.version;

    build-system = [
      pkgs.python3Packages.setuptools
      pkgs.python3Packages.setuptools-scm
    ];

    dependencies =
      [pkgs.python3Packages.qrcode]
      ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pkgs.python3Packages.pyobjc-framework-Cocoa
        pkgs.python3Packages.pyobjc-framework-Quartz
        pkgs.python3Packages.pyobjc-framework-WebKit

        # Reuse nixpkgs' PyObjC build machinery for this missing framework.
        (pkgs.python3Packages.pyobjc-framework-WebKit.overridePythonAttrs (old: {
          pname = "pyobjc-framework-ScriptingBridge";
          sourceRoot = "${old.src.name}/pyobjc-framework-ScriptingBridge";
          pythonImportsCheck = ["ScriptingBridge"];

          meta =
            old.meta
            // {
              description = "PyObjC wrappers for ScriptingBridge on macOS";
            };
        }))
      ];

    # Upstream normally compiles this during imperative setup.
    postInstall = pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/libexec"
      $CC -O2 src/sidepulse/resources/sd_eject_guard.c \
        -o "$out/libexec/sidepulse-sd-eject-guard" \
        -framework DiskArbitration \
        -framework CoreFoundation
    '';

    pythonImportsCheck =
      ["sidepulse"]
      ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        "sidepulse.status_bar"
        "ScriptingBridge"
        "WebKit"
      ];

    meta = {
      description = "SidePulse CLI and macOS companion";
      homepage = "https://github.com/inteliwear/sidepulse";
      license = pkgs.lib.licenses.mit;
      mainProgram = "sidepulse";
      platforms = pkgs.lib.platforms.darwin ++ pkgs.lib.platforms.linux;
    };
  }
)
