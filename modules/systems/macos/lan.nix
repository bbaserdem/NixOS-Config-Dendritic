# Configuring the local lan of darwin systems
{inputs, ...}: {
  flake.modules.darwin.macos = {
    lib,
    options,
    ...
  }: {
    config = lib.mkMerge [
      {
        # Dispatch local LAN keys as trusted
        security.pki.certificates = [
          (builtins.readFile (inputs.self + /assets/home-lan-ca.crt))
        ];
      }
      (
        lib.optionalAttrs (lib.hasAttrByPath ["home-manager"] options) {
          # Provision the local certificate to home-manager users as well,
          # Enables manual install
          home-manager.sharedModules = [
            {
              xdg.dataFile."certs/home-lan-ca.crt" = {
                source = inputs.self + /assets/home-lan-ca.crt;
              };
            }
          ];
        }
      )
    ];
  };
}
