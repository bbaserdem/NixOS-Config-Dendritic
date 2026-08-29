# setup of den
{
  inputs,
  den,
  ...
}: {
  # Load flake-parts modules
  imports = [
    (inputs.den.flakeModules.default or {})
    # (inputs.den.flakeModules.strict or {}) Bugged, throws immediately
  ];

  config = {
    # Den sourcing
    flake-file.inputs = {
      den.url = "github:denful/den/v0.18.0";
    };

    den = {
      # Default batteries to include
      default.includes = [
        den.batteries.define-user
        den.batteries.hostname
      ];

      schema.host = {
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
