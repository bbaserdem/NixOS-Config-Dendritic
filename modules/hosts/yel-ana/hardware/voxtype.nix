# Su-ana: hardware specific configuration for the STT tooling
{...}: {
  flake.modules.nixos.yel-ana = {
    pkgs,
    lib,
    options,
    ...
  }: {
    config = lib.optionalAttrs (lib.hasAttrByPath ["programs" "voxtype"] options) {
      # Use the Vulkan version
      programs.voxtype.package = pkgs.voxtype-vulkan;

      # Dispatch to home-manager shared modules too;
      home-manager.sharedModules = [
        ({
          options,
          lib,
          ...
        }: {
          config = lib.optionalAttrs (lib.hasAttrByPath ["programs" "voxtype"] options) {
            programs.voxtype = {
              # Configure the STT engine with whisper
              engine = "whisper";
              model.name = "large-v3-turbo";

              settings.whisper = {
                language = ["en" "tr"];
                translate = false;
                on_demand_loading = true;
              };
            };
          };
        })
      ];
    };
  };
}
