# Pi setup
# TODO: Actually set up pi
{inputs, ...}: {
  # Aspect
  den = {
    aspects.development = {
      provides.agents = {
        provides.pi = {
          name = "development/agents/pi";
          provides.to-users = {
            user,
            host,
          }: {
            name = "development/agents/pi(${user.userName}@${host.name})";
            homeManager = {...}: {
              imports = [
                inputs.self.modules.homeManager.agents-pi
              ];
            };
          };
        };
      };
    };
  };

  # Module
  flake.modules.homeManager.agents-pi = {
    pkgs,
    config,
    ...
  }: {
    key = "agents-pi#homeManager";
    # TODO; Pi module isn't present on 26.05; after migration remove this
    imports = [
      "${inputs.home-manager-unstable}/modules/programs/pi-coding-agent.nix"
    ];
    config = {
      programs.pi-coding-agent = {
        enable = true;
        package = pkgs.llm-agents.pi;

        # Set config dir to XDG
        configDir = "${config.xdg.configHome}/pi/agent";

        # Needed for pi to be able to fetch plugins etc
        extraPackages = with pkgs; [
          bun
          nodejs
          uv
        ];

        # Agent config
        context = inputs.self + /assets/ai/AGENTS.md;

        # Settings
        settings = {
          theme = "dark";
        };
      };
    };
  };
}
