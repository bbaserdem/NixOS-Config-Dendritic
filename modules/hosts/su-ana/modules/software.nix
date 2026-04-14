# Su-ana software
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # Darwin modules to import
    imports = with inputs.self.modules.darwin; [
      # Auth
      gpg
      keepassxc
      pass
      ssh
      yubikey
      # Dev tools
      docker
      editor
      python
      node
      virtualization
      vcs
      ghostty
      kitty
      # Remote
      remmina
      # Shell
      shell
      # Utilities
      archives
      btop
      tools
    ];
  };
}
