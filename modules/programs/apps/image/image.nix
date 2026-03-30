# Image related software suite
{inputs, ...}: {
  flake.modules.homeManager.image = {pkgs, ...}: {
    # Image related software suite

    # Image modules
    imports = with inputs.self.modules.homeManager; (
      [
        blender
        gimp
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isLinux
        then [
        ]
        else if pkgs.stdenv.hostPlatform.isDarwin
        then []
        else []
      )
    );
  };
}
