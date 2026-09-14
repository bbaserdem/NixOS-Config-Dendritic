# Pi setup
# TODO: Actually set up pi
{inputs, ...}: {
  # Module
  flake.modules.homeManager.llm-pi = {
    pkgs,
    config,
    ...
  }: {
    # TODO; Pi module isn't present on 26.05; after migration remove this
    imports = [
      "${inputs.home-manager-unstable}/modules/programs/pi-coding-agent.nix"
    ];
    config = {
      programs.pi-coding-agent = {
        enable = true;
        packages = pkgs.llm-agents.pi;

        # Set config dir to XDG
        configDir = "${config.xdg.configHome}/pi/agent";
        # Needed for pi to fetch things
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
