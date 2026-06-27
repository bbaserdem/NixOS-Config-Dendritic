# Voxtype configuration
{...}: {
  flake.modules.homeManager.wolframite = {
    lib,
    options,
    ...
  }: {
    # Configure voxtype on user level
    config = lib.optionalAttrs (lib.hasAttrByPath ["services" "voxtype"] options) {
      services.voxtype = {
      };
    };
  };
}
