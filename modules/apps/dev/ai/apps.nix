# Claude code global setup
{...}: {
  flake.modules = {
    darwin.ai = {...}: {
      # Enable userspace tools
      homebrew = {
        brews = [
          "forgecode"
        ];
        casks = [
          "repo-prompt"
          "claude"
          "claude-code@latest"
          "codex"
          "codex-app"
          "codexbar"
          "droid"
          "zed"
        ];
      };
    };
  };
}
