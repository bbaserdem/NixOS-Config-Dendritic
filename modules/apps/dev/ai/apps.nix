# Claude code global setup
{...}: {
  flake.modules = {
    darwin.ai = {...}: {
      # Enable userspace tools
      homebrew = {
        casks = [
          # External context tools
          "repo-prompt"
          # Agentic coding
          "claude-code@latest"
          "codex"
          # AI Apps
          "claude"
          "codex-app"
          # Harnesses
          "droid"
        ];
        brews = [
          # Harnesses
          "forgecode"
          "opencode"
        ];
      };
    };
  };
}
