# AI tools
{inputs, ...}: {
  flake = {
    modules = {
      homeManager.ai-pi = {
        pkgs,
        config,
        ...
      }: {
        # Config module is not in stable home-manager;
        # This can be discarded after bump to version 26.11
        imports = [
          "${inputs.home-manager-unstable}/modules/programs/pi-coding-agent.nix"
        ];
        config = {
          programs.pi-coding-agent = {
            enable = true;
            package = pkgs.llm-agents.pi;
            configDir = "${config.xdg.configHome}/pi/agent";
            extraPackages = with pkgs; [
              bun
              nodejs
              uv
            ];

            # Agent configuration
            context = inputs.self + /assets/ai/AGENTS.md;

            # Settings
            settings = {
              theme = "dark";
            };
          };
        };
      };
    };
  };
}
