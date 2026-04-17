# Su-ana development config
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules for development
    imports = with inputs.self.modules.darwin; [
      ai
      docker
      editor
      virtualization
      vcs
      shell
      # Languages
      node
      python
    ];
  };
}
