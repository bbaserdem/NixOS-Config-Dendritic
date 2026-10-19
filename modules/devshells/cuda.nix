# DevShell for python development for ML projects
# Only available in Linux, GPU's are not supported in Darwin anyway
# TODO: Clean this to not have geospatial stuff; only cuda.
{...}: {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    cudaPkgs = with pkgs.cudaPackages; [
      cudatoolkit
      cudnn
      cuda_cudart
      libcutensor
      libcublas
      libcurand
      libcusparse
    ];
    # Complete XCB and X11 libraries needed by Qt5 XCB plugin
    x11Pkgs = with pkgs; [
      libx11
      libxi
      libxrender
      libxext
      libxfixes
      libxcursor
      libxcomposite
      libxdamage
      libxinerama
      libxau
      libxdmcp
      libxcb
      libxcb-util
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      libxkbcommon
    ];
    # GCC to use
    gccPkg = pkgs.gcc13;
  in {
    devShells.cuda = pkgs.mkShell ({
        packages = with pkgs;
          [
            # Python projects use uv tooling for python environment
            # We supply CUDA only, not pytorch. That's on uv
            uv
            # Node.js for claude and codex
            nodejs-slim
            pnpm
            # Tooling for agents
            ripgrep
            shellcheck
            nixd
            bash-language-server
            socat
            # Doc rendering
            mdbook
            mdbook-mermaid
            # Generic tooling commonly used for ML
            python3Packages.huggingface-hub
            ffmpeg
            postgresql
          ]
          ++ (lib.optionals (pkgs.stdenv.hostPlatform.isLinux) (
            cudaPkgs
            ++ x11Pkgs
            ++ [gccPkg]
            ++ (with pkgs; [
              # Sandboxing
              bubblewrap
              # OpenCV and computer vision
              opencv4
              # PyArrow dependencies
              arrow-cpp
              # Build tools and compilers
              pkg-config
              cmake
              ninja
              gcc
              # Additional system libraries
              zlib
              libjpeg
              libpng
              libtiff
              eigen
              # Essential GUI dependencies only (minimal set for PyQt5)
              glib
              glibc
              libGL
              libxcb
              xcbutilxrm
              fontconfig
              freetype
              dbus
              # Libraries needed by Qt5 XCB plugin
              tk
              tcl
            ])
          ));
        shellHook =
          ''
            # Setup Python via uv
            export UV_PYTHON_PREFERENCE=only-managed

            # Sync dependencies if pyproject.toml exists
            if [ -f "pyproject.toml" ]; then
              # Create venv if it doesn't exist
              if [ ! -d ".venv" ]; then
                echo "Creating Python virtual environment with uv..."
                uv venv
              fi

              # Sync project deps
              uv sync --all-extras
            fi
          ''
          + (lib.optionalString (pkgs.stdenv.hostPlatform.isLinux) ''
            # Set CC to GCC 13 to avoid the version mismatch error
            export PATH=${pkgs.gcc13}/bin:$PATH
          '')
          + (lib.optionalString (pkgs.stdenv.hostPlatform.isDarwin) ''
            echo "Darwin doesn't support CUDA"
          '');
      }
      // (lib.optionalAttrs (pkgs.stdenv.hostPlatform.isLinux) {
        # Cuda env variables
        CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
        CUDA_HOME = "${pkgs.cudaPackages.cudatoolkit}";
        CUDA_ROOT = "${pkgs.cudaPackages.cudatoolkit}";

        # Set CC to GCC 13 to avoid the version mismatch error
        CC = "${gccPkg}/bin/gcc";
        CXX = "${gccPkg}/bin/g++";

        # Environment variables to help packages find system libraries
        GDAL_DATA = "${pkgs.gdal}/share/gdal";
        PROJ_LIB = "${pkgs.proj}/share/proj";
        GDAL_LIBRARY_PATH = "${pkgs.gdal}/lib";
        GEOS_LIBRARY_PATH = "${pkgs.geos}/lib";

        # OpenCV
        OpenCV_DIR = "${pkgs.opencv4}/lib/cmake/opencv4";
        OPENCV_INCLUDE_DIRS = "${pkgs.opencv4}/include/opencv4";

        # Arrow
        ARROW_HOME = "${pkgs.arrow-cpp}";

        # Library path including CUDA and essential GUI libraries
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
          ["/run/opengl-driver"]
          ++ cudaPkgs
          ++ x11Pkgs
          ++ (with pkgs; [
            glib
            glibc
            libGL
            xcbutilxrm
            fontconfig
            freetype
            dbus
            tk
            tcl
          ])
        );

        # Set LIBRARY_PATH to help the linker find the CUDA static libraries
        LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
          cudaPackages.cudatoolkit
        ]);

        # PKG_CONFIG_PATH for all libraries
        PKG_CONFIG_PATH =
          "${pkgs.gdal}/lib/pkgconfig"
          + ":"
          + "${pkgs.opencv4}/lib/pkgconfig"
          + ":"
          + "${pkgs.arrow-cpp}/lib/pkgconfig"
          + ":"
          + "${pkgs.postgresql}/lib/pkgconfig";
      }));
  };
}
