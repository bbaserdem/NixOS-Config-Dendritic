# Su-ana development config
{inputs, ...}: {
  flake.modules.darwin.su-ana = {...}: {
    # System configuration

    # Load modules for development
    imports = with inputs.self.modules.darwin; [
      docker
      virtualization
      vcs
      # Languages
      node
      python
      lean
      # Editors
      nvim
      neovide
      vscodium
      zed
      # AI tools
      ai
      ai-claude
      ai-codegraph
      ai-codex
      ai-opencode
      ai-forgecode
      ai-droid
    ];
  };
}
