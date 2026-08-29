# General systems boilerplate for den
{
  inputs,
  den,
  ...
}: {
  den = {
    # Always include the base system aspect in every host scope
    schema.host.includes = [
      den.aspects.system
    ];

    # System aspect generic defaults
    aspects.system = {
      os = {...}: {
        imports = [
          inputs.self.modules.generic.filesystem
        ];
      };
    };
  };
}
