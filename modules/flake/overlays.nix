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

        # yt-dlp fails on darwin right now
        pythonPackagesExtensions =
          (prev.pythonPackagesExtensions or [])
          ++ (lib.optionals prev.stdenv.hostPlatform.isDarwin [
            (pyFinal: pyPrev: {
              yt-dlp-ejs = pyPrev.yt-dlp-ejs.override {
                nodejs = final.nodejs_22;
              };
            })
          ]);
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
