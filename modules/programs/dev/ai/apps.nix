# Claude code global setup
{...}: {
  flake.modules = {
    darwin.ai = {...}: {
      # Enable userspace tools
      homebrew = {
        casks = [
          "repo-prompt"
          "claude"
          "claude-code@latest"
          "codex"
          "codex-app"
          "codexbar"
        ];
      };
    };
  };
}
