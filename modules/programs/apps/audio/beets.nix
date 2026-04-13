# Enabling beets
{...}: {
  flake.modules.homeManager.beets = {
    pkgs,
    lib,
    ...
  }: {
    config = lib.mkMerge [
      {
        # Enable beets in userspace
        # The rest of the config should be user-specific
        programs.beets = {
          enable = true;
        };
      }
      (
        lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
          home.packages = with pkgs; [
            picard
          ];
        }
      )
    ];
  };
}
