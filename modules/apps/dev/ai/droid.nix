# AI tool - factory.ai droid
{...}: {
  flake = {
    modules = {
      homeManager.ai-droid = {pkgs, ...}: {
        # Harnesses
        home.packages = with pkgs.llm-agents; [
          droid
        ];
      };
    };
  };
}
