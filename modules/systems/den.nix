# General systems boilerplate for den
{
  inputs,
  den,
  ...
}: {
  den = {
    # Always include the base system and shell aspect in every host scope
    schema.host.includes = [
      den.aspects.system
      den.aspects.shell
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
