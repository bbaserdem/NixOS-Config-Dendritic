# Package overlays
{
  inputs,
  lib,
  ...
}: {
  flake = {
    overlays = {
      # Our system overlays

      modifications = final: prev: {
        # Modifications to existing packages
      };

      # Local python package nameset
      localPythonPackages = final: prev: {
        pythonPackagesExtensions =
          (prev.pythonPackagesExtensions or [])
          ++ [
            (pyFinal: pyPrev: {
              local =
                (pyPrev.local or {})
                // (
                  inputs.packages
                  |> builtins.readDir
                  |> (lib.filterAttrs (
                    name: type:
                      (type == "directory")
                      && (builtins.pathExists (inputs.packages + "/${name}/python.nix"))
                  ))
                  |> lib.attrNames
                  |> (names:
                    lib.genAttrs names (
                      name:
                        pyFinal.callPackage (inputs.packages + "/${name}/python.nix") {}
                    ))
                );
            })
          ];
      };
    };
  };
}
