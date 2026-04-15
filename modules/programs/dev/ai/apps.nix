# Claude code global setup
{...}: {
  flake.modules = {
    darwin.ai = {...}: {
      # Enable userspace tools
      homebrew = {
        casks = [
          "repoprompt"
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
