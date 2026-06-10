# AI tools
{...}: {
  flake = {
    modules = {
      homeManager.ai-forgecode = {pkgs, ...}: {
        # Harnesses
        home.packages = with pkgs.llm-agents; [
          forgecode
        ];
      };
    };
  };
}
