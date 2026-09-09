# New host type droid; stub that does not produce output
# Generic aspect walk does not happen besides host types nixos and darwin;
# We do it explicitly with policies here
# TODO; Actually built a nixOnDroidConfiguration output for this type
{
  den,
  lib,
  ...
}: {
  den = {
    classes.droid = {
      description = "Android device (metadata-only for now)";
    };

    # Redo the host scope walk for droid entities
    policies.system-to-droid-hosts = {system, ...}:
      (den.hosts.${system} or {})
      |> lib.filterAttrs (_: host: host.class == "droid")
      |> builtins.attrValues
      |> builtins.map (
        host:
          den.lib.policy.resolve.to "host" {
            inherit host;
          }
      );

    schema = {
      flake-system.includes = [
        den.policies.system-to-droid-hosts
      ];

      host = {config, ...}: {
        config = lib.mkIf (config.class == "droid") {
          instantiate = _:
            throw "Droid host `${config.name}` is metadata-only; can't be instatiated.";
          intoAttr = lib.mkForce [];
        };
      };
    };
  };
}
