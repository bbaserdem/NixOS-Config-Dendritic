# Configuring gimp
{inputs, ...}: {
  # Aspect
  den = {
    aspects.image = {
      provides.gimp = {
        name = "image/gimp";
        provides.to-users = {
          user,
          host,
        }: {
          name = "image/gimp(${user.userName}@${host.name})";
          homeManager = {...}: {
            imports = [
              inputs.self.modules.homeManager.gimp-settings
            ];
          };
        };
      };
    };
  };
  # Module
  flake.modules.homeManager.gimp-settings = {
    pkgs,
    lib,
    ...
  }: {
    key = "gimp-settings#homeManager";
    config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux) {
      home.packages = with pkgs; [
        gimp-with-plugins # Bundles with all plugins not marked broken
      ];
    };
  };
}
