# Secret provisioning for this user
{inputs, ...}: {
  flake.modules.homeManager.batuhan = {
    lib,
    options,
    config,
    ...
  }: {
    config = lib.mkIf (lib.hasAttrByPath ["sops"] options) {
      # Listenbrainz token
      # sops.secrets.listenbrainz = {};
      sops = {
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = inputs.self + /secrets/user/wolframite/secrets.yaml;
      };
    };
  };
}
