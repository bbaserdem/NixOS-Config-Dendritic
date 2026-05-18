# Claude code global setup
{...}: {
  flake.modules = {
    darwin.ai = {...}: {
      # Enable userspace tools
      homebrew = {
        casks = [
          # External context tools
          "repo-prompt"
          # Harnesses
          "droid"
        ];
        brews = [
          # Harnesses
          "forgecode"
        ];
      };
    };
  };
}
