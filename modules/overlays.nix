# Package overlays
{
  inputs,
  lib,
  ...
}: {
  nixpkgs.overlays = [
    inputs.self.overlays.modifications
    inputs.self.overlays.unstablePackages
    inputs.self.overlays.localPythonPackages
  ];

  # Our system overlays
  flake.overlays = {
    # Unstable packages in pkgs
    unstablePackages = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config = final.config;
        overlays = [
          inputs.self.overlays.localPythonPackages
        ];
      };
    };

    # Modifications to existing packages
    modifications = final: prev: {
      # Pywalfox is broken; badly packaged and needs patching
      pywalfox-native = prev.pywalfox-native.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.jq];
        postInstall =
          (old.postInstall or "")
          + ''
            mkdir -p $out/lib/mozilla/native-messaging-hosts

            jq --arg bin "$out/bin/pywalfox" \
              '.path = $bin' \
              "${old.src}/pywalfox/assets/manifest.json" \
              > "$out/lib/mozilla/native-messaging-hosts/pywalfox.json"
          '';
      });
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
}
