# Su-ana secret provisioning
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # Load modules that configure the system
    imports = with inputs.self.modules.darwin; [
      secrets
    ];
    sops.defaultSopsFile = inputs.self + /secrets/host/su-ana/secrets.yaml;
  };
}
