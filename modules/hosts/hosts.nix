# Den setup for host realization
{
  inputs,
  den,
  ...
}: {
  den = {
    # Default batteries to include for hosts
    default.includes = [
      den.batteries.hostname
    ];

    # Host fixing
    schema = {
      host = {
        config,
        lib,
        ...
      }: {
        config = lib.mkMerge [
          # Fix hard-coded naming of nix-darwin flake input
          (
            lib.mkIf (config.class == "darwin") {
              instantiate = lib.mkDefault inputs.nix-darwin.lib.darwinSystem;
            }
          )
          # Stub host output path for homeManager class host
          (
            lib.mkIf (config.class == "homeManager") {
              intoAttr = [];
            }
          )
        ];
      };
    };
  };
}
