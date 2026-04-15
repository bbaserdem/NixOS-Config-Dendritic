# Su-ana secrets config
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules for auth configuration
    imports = with inputs.self.modules.darwin; [
      gpg
      keepassxc
      pass
      polkit
      ssh
      yubikey
    ];
  };
}
