# Od-ata system configuration
{inputs, ...}: {
  flake.modules.nixos.od-ata = {...}: {
    # System configuration

    # Load modules that configure the system
    imports = with inputs.self.modules.nixos; [
      wolframite
    ];

    # Allow ssh-ing into the system user
    users.users.wolframite = {
      openssh.authorizedKeys.keyFiles = [(inputs.self + /assets/od-ata_ssh.pub)];
    };
  };
}
