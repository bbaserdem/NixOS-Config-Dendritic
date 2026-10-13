# Typescript editing plugins
{...}: {
  flake.wrappers.neovim = {pkgs, ...}: {
    config.specs.typescript = {
      lazy = true;
      data = null;
      runtimePackages = with pkgs.unstable; [
        # TODO: Temporary fix; remove after unstable advances
        # typescript-language-server
        (typescript-language-server.overrideAttrs (old: {
          pnpmDeps = old.pnpmDeps.overrideAttrs (_: {
            outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
          });
        }))
      ];
    };
  };
}
