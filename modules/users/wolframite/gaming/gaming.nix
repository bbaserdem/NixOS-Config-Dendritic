# Set personal gaming config entry point
{
  inputs,
  den,
  ...
}: {
  # User aspect that loads in gaming settings
  den = {
    aspects.wolframite = {
      includes = [
        den.aspects.wolframite._.gaming
      ];

      # Gaming aspects
      provides.gaming = {
        host,
        user,
      }: {
        name = "wolframite/gaming(${user.userName}@${host.name})";
        homeManager = {
          lib,
          options,
          ...
        }: {
          # Import steam module
          imports = with inputs.self.modules.homeManager; [
            wolframite-steam
          ];
          config =
            lib.optionalAttrs
            (lib.hasAttrByPath ["programs" "steam" "config"] options)
            ( # Brotato memory leaks on yertengri
              # NVIDIA CPMMListener report
              # https://forums.developer.nvidia.com/t/opengl-driver-thread-cpmmlistener-allocates-large-amounts-of-ram-exactly-10-minutes-after-launch-rimworld-unity/385727
              lib.mkIf (host.name == "yertengri")
              {
                programs.steam.config.apps."1942280" = {
                  env = {
                    MESA_LOADER_DRIVER_OVERRIDE = "zink";
                    __GLX_VENDOR_LIBRARY_NAME = "mesa";
                  };
                };
              }
            );
        };
      };
    };
  };
}
